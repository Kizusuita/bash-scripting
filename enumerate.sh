#!/bin/bash

declare -a iface
declare -a ifaces
IFS=' '

#Collect all interfaces
cidr_to_netmask() {
	local i mask=""
	local cidr=$1
	local full_octets=$((cidr / 8))
	local remainder=$((cidr % 8))

	for ((i=0; i<4; i++)); do
		if ((i < full_octets)); then
			mask+="255"
		elif ((i == full_octets)); then
			mask+=$(( 256 - 2**(8 - remainder) )) #Handles partial mask portion
		else
			mask+="0"
		fi

		[[ $i -lt 3 ]] && mask+="." #This just adds the . between the octets, because every 3rd iteration you'd add a dot
	done

	echo "$mask"
}

mapfile -t ifaces < <(ip -o link show | awk -F': ' '{print $2}' | grep -v '^lo$') #Print 2nd output field, IPaddr, skip loopback

i=0

# Use an indexed array to store the interface data
declare -a iface

for iface_name in "${ifaces[@]}"; do
	state=$(ip link show "$iface_name" | awk '/state/ {print $9}') #State, print 9th field
	mac=$(ip -o link show "$iface_name" | awk '{print $17}') #MAC address
	ip=$(ip -o -4 addr show "$iface_name" | awk '{print $4}') #-o = One line, -4 = only IPv4, print 4th field

	if [[ -n $ip && "$ip" =~ / ]]; then
		cidr=${ip#*/}
		mask=$(cidr_to_netmask "$cidr")
	else
		ip="none"
		mask="none"
	fi

	iface[$i]="$iface_name|$state|$mac|$ip|$mask" #The way I was doing it is wrong because it won't store a list in a single array element. I'm just storing it as a single string and then storing it later by splitting it at the delimiter.

	i=$((i+1))
done

#-------- Get network subnet details & Ping
ip_to_int() {
	local IFS=.
	read -r i1 i2 i3 i4 <<< "$1"
	echo $(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))
}

int_to_ip() {
	local ip=$1
	echo "$(( (ip >> 24) & 255 )).$(( (ip >> 16) & 255 )).$(( (ip >> 8) & 255 )).$(( ip & 255 ))"
}

is_alive(){
	ping -c 1 -W 1 "$1"  > /dev/null 2>&1
	return $? #Return exit code of previous command
}

#--- For my subshells later ---
export -f is_alive
export -f int_to_ip
#------------------------------

for (( i=0; i<${#iface[@]}; i++ )); do
	IFS='|' read -r name state mac ip mask <<< "${iface[$i]}"

	ip_int=$(ip_to_int "$ip")
	mask_int=$(ip_to_int "$mask")

	network_int=$(( ip_int & mask_int ))
	broadcast_int=$(( network_int | (~mask_int & 0xFFFFFFFF) )) #Broadcast address

	network=$(int_to_ip "$network_int")
	broadcast=$(int_to_ip "$broadcast_int")

	host_first=$(( network_int + 1 ))
	host_last=$(( broadcast_int - 1 ))

	use_range_1=$(int_to_ip host_first)
	use_range_2=$(int_to_ip host_last)

	#stupid array index access bullshit >:(
	network_details[$i]="$ip|$mask|$network|$broadcast"

	printf "Interface %s:\n  Name: %s\n  IP: %s\n  Mask: %s\n  Network ID: %s\n  Broadcast Addr: %s\n  Useable Range: %s - %s\n\n" "$((i + 1))" "$name" "$ip" "$mask" "$network" "$broadcast" "$use_range_1" "$use_range_2"

	{
		for ((ip_int = host_first; ip_int <= host_last; ip_int++)); do
			int_to_ip "$ip_int"
		done
	} | xargs -P10 -I{} bash -c 'is_alive "$0" && "echo Alive: $0"' {}

done

#-------------- Above here works for sure. --------------

:<<'note'
	> sweep.txt #Clear the file every time

	{
		for ((ip_int = host_first; ip_int <= host_last; ip_int++)); do
			int_to_ip "$ip_int" #Convert int to IP
		done
	} | xargs -P10 -I{} bash -c 'is_alive "$0" && flock output.txt -c "echo Alive: $0"' {}

done



I'm just gonna make this a whole note so I don't have another giant comment in the middle of my code. Explanation of xargs: The command itself takes input (normally file/pipe), makes commands from that and then executes them. It's sorta like a bridge between the data itself and the action execution of the code. a.k.a., it takes a list of things and runs a command on each of them. Why do this instead of just running each piece in a loop?... well because it handles long lists, spaces, quotes, etc. including parallelism a lot more safely and nicely. And I want to be able to use this code on big networks if I want, so.... very long lists.

The 0 is needed instead of the 1 because of how bash -c works. Bash -c is being passed a script string, which is "$0". The {} becomes the script string, or rather the above { for; do done } is the script string, and that's what it's being passed. The output from the is put into $0, instead of $1 like a "normal" arugment in the parent shell. Normally you only have 1 arg for xargs too, so it's typically always $0 when calling the output from your script string.

Flock is another new command, great I know. It's "file lock," and prevents multiple processes from accessing the same file at the same time. This'll prevent corruption or a jumbled mess occurring when I start writing 200 processes to the same file lmfao. The -c just lets me lock the file directly by the file name. It's good for parallelized or bg scripts that are all writing to the same file.

The flags mean as follows:
-n1 Run command with 1 arg @ a time (aka 1 ip at a time) <--- Don't need this if you run it with -I{} {}
-P50 Run 50 processes in parallel (Might change how many this is later? Probably lol.) When 1 finishes, it'll start another until input is done
-I{} Replaces {} in the command with input
"bash -c 'is_alive "$0" && echo "Alive: $0"'" Runs a new bash process executing the script "is_alive "$0" && echo "Alive: $0"". It then calls my function is_alive, and if it's successful (&&) it'll echo that the host is alive.
& Run them in the background

xargs -P50 -I{} bash -c 'is_alive "$1" && echo "Alive: $1"' {}


#Scan alive hosts

summary="summary.txt"
scan_dir="scans"
lockfile="/var/lock/scan_lock"

mkdir -p "$scan_dir" #makes directory
: > "$summary" #outputs summary file to directory above
echo "" >> $summary

if [[ ! -s sweep.txt ]]; then
	echo "No alive hosts found, exiting..."
	exit 0
fi

ports="1-1024" #Change as needed
timing="-T2" #Less likely to trigger IDS/IPS thresholds, change as desired but it'll be louder
scan_delay="100ms" #Forces delay between probes so it's less traffic created
max_retries=2 #The more this is, the more network traffic you'll create
args="-sT $timing --scan-delay $scan_delay --max-retries $max_retries -p $ports -oG -" #-sT so I can run without root, -oG so it's greppable

scan_host() {
	local host="$1"
	local ts=$(date --utc +'%F_%T') #timestamped

	local outfile="${scan_dir}/${host}.nmap" #actual output file
	local tmpfile=$(mktemp "/tmp/nmap_${host}") #tmp log file

	if ! nmap ${args} "$host" >"$tmpfile" 2>/dev/null; then #error handle
		echo "nmap failed for $host" >&2 #>&2 means redirect to message errout
	fi

	cp -f "$tmpfile" "${outfile}.grep" #Save grepable and human-readable output, want grep for rest of script
	nmap -sT ${timing} -p "${ports}" --max-retries "${max_retries}" "$host" -oN "${outfile}.txt" >/dev/null 2>&1

:<<'note2'
2>&1 like I said earlier directs all output to null, so no terminal messages.
note2

	local ports_field open_ports
	ports_field=$(awk -F'Ports: ' '/Ports: /{print $2}' "$tmpfile" || true) #Extract open ports from grepable output
	if [[ -z "$ports_field" ]]; then
		open_ports="none"
	else
		open_ports=$(echo "$ports_field" | tr ',' '\n' | awk -F'/' '/open/ {print $1}' | paste -sd',' -)
		[[ -z "$open_ports" ]] && open_ports="none"
	fi

	flock "$lockfile" -c "printf '%s,%s,%s\n' \"$ts\" \"$host\" \"$open_ports\" >> \"$summary\"" #Append summary under flock
	rm -f "$tmpfile"

	printf '[%s] %s -> %s\n' "$ts" "$host" "$open_ports"
}

export -f scan_host
export scan_dir summary lockfile args ports timing scan_delay max_retries

echo "Starting nmap scans on alive hosts..."

cat sweep.txt | xargs -n1 -P5 -I{} bash -c 'scan_host "$0"' {}

echo "All scans completed. Results in $scan_dir/, summary in $summary."

#testing
for (( i=0; i<${#iface[@]}; i++ )); do
	details_var="network_details_${i}[@]"
	details=("${!details_var}") #The inside of this is called an "indirect expansion". In order to assign EACH ELEMENT of this array to the elements of the details array, you need to tell bash by the (), which lowkey just means create an array. Without it, you just get a string assigned to details[0]. Same applies to above, but it doesn't need the () because I'm not passing a whole array, I'm just passing a single element.
	echo "IP: ${details[0]}"
	echo "Mask: ${details[1]}"
	echo "Network: ${details[2]}"
	echo -e "Broadcast: ${details[3]}\n"
done
done
note

