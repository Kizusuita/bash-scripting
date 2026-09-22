#!/bin/bash

declare -a iface
declare -a ifaces
IFS=' '

echo "    ╭─●────●────●─────────────●────●─╮"
echo "    │   (\_/)                        ●│"
echo "    |  ( •_• )   Bunn1N37          ──┤│"
echo "    │  /    >  5n34k1ng 7hr0ugh n37s. │"
echo "    ╰─●────●────●─────────────●────●─╯"
echo ""
echo -e "Welcome to Bunn1N37, a ping sweeper and port scanner. Please wait while Network Details are collected.\n"

sleep 5

:<<'Program Information'
---> SCRIPT NAME: bunninet.sh
---> DESCRIPTION: This script will automatically pull all interface IP's on host, find network details and then perform -sT nmap scan on all live hosts on host network.
---> DATE: 10/16/25
---> Usage: ./bunninet.sh
Program Information

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
export sweep_txt
#------------------------------

sweep_txt="sweep.txt"
network_txt="network_details.txt"

echo "" > $sweep_txt #clear each run
echo "" > $network_txt

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

	printf "Interface %s:\n  Name: %s\n  IP: %s\n  Mask: %s\n  Network ID: %s\n  Broadcast Addr: %s\n  Useable Range: %s - %s\n\n" "$((i + 1))" "$name" "$ip" "$mask" "$network" "$broadcast" "$use_range_1" "$use_range_2" >> "$network_txt"

	{
		for ((ip_int = host_first; ip_int <= host_last; ip_int++)); do
			int_to_ip "$ip_int"
		done
	} | xargs -P100 -Iip bash -c 'is_alive "$1" && flock /tmp/sweep.lock -c "echo $1 >> $sweep_txt"' _ ip
done

echo -e "Network Details gathered... starting scan on live hosts...\n"
echo "*** THIS MAY TAKE AWHILE, PLEASE BE PATIENT ***"

sleep 5

:<<'note'
I'm just gonna make this a whole note so I don't have another giant comment in the middle of my code. Explanation of xargs: The command itself takes input (normally file/pipe), makes commands from that and then executes them. It's sorta like a bridge between the data itself and the action execution of the code. a.k.a., it takes a list of things and runs a command on each of them. Why do this instead of just running each piece in a loop?... well because it handles long lists, spaces, quotes, etc. including parallelism a lot more safely and nicely. And I want to be able to use this code on big networks if I want, so.... very long lists.

So, let's explain this one more time... the xargs needs a "dummy" name for the script name. That is the _. The actual code running and output is put into {}, the one at the end of the line. That's "$1". If I want more output, I can put other stuff on the end to name it. Technically 	I could name {} to ip to make it less confusing ... actually I'm gonna go back and do that now.

Flock is another new command, great I know. It's "file lock," and prevents multiple processes from accessing the same file at the same time. This'll prevent corruption or a jumbled mess occurring when I start writing 200 processes to the same file lmfao. The -c just lets me lock the file directly by the file name. It's good for parallelized or bg scripts that are all writing to the same file.

The flags mean as follows:
-n1 Run command with 1 arg @ a time (aka 1 ip at a time) <--- Don't need this if you run it with -I{} {}
-P50 Run 50 processes in parallel (Might change how many this is later? Probably lol.) When 1 finishes, it'll start another until input is done
-I{} Replaces {} in the command with input
"bash -c 'is_alive "$0" && echo "Alive: $0"'" Runs a new bash process executing the script "is_alive "$0" && echo "Alive: $0"". It then calls my function is_alive, and if it's successful (&&) it'll echo that the host is alive.
& Run them in the background
note

if [[ ! -s sweep.txt ]]; then #error handle for no alive hosts
	echo "No alive hosts found, exiting..."
	exit 0
fi

#------------- NMAP SETTINGS : CHANGE AS NEEDED

ports="1-1024" #Change as needed
timing="-T2" #Less likely to trigger IDS/IPS thresholds, change as desired but it'll be louder
scan_delay="100ms" #Forces delay between probes so it's less traffic created
max_retries=2 #The more this is, the more network traffic you'll create
args="-sT $timing --scan-delay $scan_delay --max-retries $max_retries -p $ports " #-sT so I can run without root, -oG so it's greppable

summary_csv="scan_summary.csv"
combined_gnmap="all_hosts.gnmap"
combined_txt="all_hosts.nmap.txt"
stderr_dir="/tmp/nmap_stderr"

mkdir -p "$stderr_dir"

read -r -a nmap_args <<< "$args" #This prevents the shell from doing stupid shit to the args line.

echo -e "----- Nmap Details for all Alive Hosts in \"sweep.txt\" -----\n" > "$summary_csv"

#All of the {} around variables make it so the shell parses the information correctly. For stuff like .txt it's gonna look for "$hostfile.txt" as a whole string, rather than "${hostfile}.txt" for example.

scan_host() {
	local host="$1"
	local ts
	ts=$(date -u +'%F_%T')

	local out_gnmap="${host}.gnmap" #Grepable so I can organize the data later in the summary, standardized in contrast to human readable
	local err_file="/tmp/nmap_${host}.stderr" #I feed the error to here, so they don't append into the summary

	#Run nmap once --> send grepable and human-readable outputs to per-host files
	if ! nmap "${nmap_args[@]}" -oG "$out_gnmap" "$host" > /dev/null 2> "$err_file"; then #The /dev/null will make nmap not have any output in terminal :) And the ! is a neat little way to write if command failed instead of writing both if then else.
		echo "nmap failed for $host (see $err_file)" >&2
		return 1
	fi

	#Parse open ports from grepable output
	local ports_field open_ports filtered_ports
	ports_field=$(awk -F 'Ports: ' '/Ports: /{print $2}' "$out_gnmap")

	if [[ -z "$ports_field" ]]; then
		open_ports="none"
		filtered_ports="none"
	else
		open_ports=$(echo "$ports_field" | tr ',' '\n' | awk -F'/' '$2 == "open" {print $1}' | paste -sd',' -) #Paste is another super cool command I found while working on this, it takes all the lines of a file and puts it into one line, then separates lines by the -d (delimiter). The last - just means "from stdin," so it takes it from the echo
		filtered_ports=$(echo "$ports_field" | tr ',' '\n' | awk -F'/' '$2 == "filtered" {print $1}' | paste -sd',' -)
		#The tr in each breaks the lines at the ports, putting each port on a new line
		#Which in turn is great because then you can put them all organized and together after filtering with awk and then listing with paste :)

		#If empty, set to none~
		[[ -z "$open_ports" ]] && open_ports="none"
		[[ -z "$filtered_ports" ]] && filtered_ports="none"
	fi

	#Parse host IP and OS info from grepable output
	local host_ip os_name
	host_ip=$(awk '/^Host: /{print $2; exit}' "$out_gnmap") #Takes the first field after 'Host:' which is the IP address
	os_name=$(awk -F'OS: ' '/OS: /{print $2; exit}' "$out_gnmap") #Takes the text after 'OS:' if OS detection was successful
	[[ -z "$os_name" ]] && os_name="Unknown OS" #If OS detection failed or wasn't run, mark it as Unknown OS

	#Print summary line with host IP and OS info included
	printf '[%s]: Host:%s (%s) ---> OS:%s  OPEN:%s  FILTERED:%s\n' "$ts" "$host" "$host_ip" "$os_name" "$open_ports" "$filtered_ports" >> "$summary_csv"
}

export -f scan_host
export summary_csv args ports timing scan_delay max_retries

cat $sweep_txt | xargs -P5 -I{} bash -c 'scan_host "$1" && echo "Host scans completed, starting next... " && sleep 2' _ {} #This will pipe whatever is in the sweep.txt into scan_host

cat $network_txt >> "$summary_csv"

rm -f ./*.gnmap "./$network_txt" "./$sweep_txt"
rm -f /tmp/nmap_*.stderr

echo -e "\nAll scans completed!~ All details can be found in ./scan_summary.csv"

