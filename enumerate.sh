#!/bin/bash

declare -a raw
declare -a ipaddr
IFS=' '

#Collect all interfaces
cidr_to_netmask() {
	local i mask=""
	local cidr=$1
	local full_octets=$((cidr / 8))
	local remainder=$((cidr % 8))

	for ((i=0; i<4; i++)); do
		if ((i < full_octets)); then
			mask+=255
		elif ((i == full_octets)); then
			mask+=$(( 256 - 2**(8 - remainder) ))
		else
			mask+=0
		fi
	
		[[ $i -lt 3 ]] && mask+=.
	done
	
    echo "$mask"
}

mapfile -t ifaces < <(ip -o link show | awk -F': ' '{print $2}')

i=0

for iface in "${ifaces[@]}"; do
	read -r state mac <<< "$(ip link show "$iface" | awk '/link\// {print $9} NR==1 {print $9}')"

	ip_info=$(ip -o -4 addr show "$iface" | awk '{print $4}')
    
	if [[ -n $ip_info ]]; then
		cidr=${ip_info#*/}
		mask=$(cidr_to_netmask "$cidr")
	else
		ip="none"
		mask="none"
	fi
	
	declare -a "iface_$i=( $iface $state $mac $ip $mask )"
	i=$((i+1))
done

#Get network subnet details & Ping
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
	ping -c 1 -W 1 "$1" > /dev/null 2>&1 #The 2>&1 makes it have no output, redirection
	return $? #$? is a special character, that returns the exit code of the previous cmd exe
}

export -f is_alive int_to_ip #This is so my subshells can process these functions later.

for (( i=0; i<${#raw[@]}; i++ )); do #Len of raw so it counts all addresses it found in the beginning
	ip_var="ipaddr_${i}[0]"
	mask_var="ipaddr_${i}[1]"
    
	ip="${!ip_var}" #I have to write it like this so I can expand the VALUE of ip_var as a variable name, then expand that variable. If I don't, it's a "bad subsitution" error because bash doesn't handle stuff like "${ipaddr_$1[0]} correctly.
	mask="${!mask_var}"

	ip_int=$(ip_to_int "$ip")
	mask_int=$(ip_to_int "$mask")

	network_int=$(( ip_int & mask_int ))
	broadcast_int=$(( network_int | (~mask_int & 0xFFFFFFFF) )) #OR so it returns the numbers in layman's terms added together, putting the 1's in the binary rep where the 0's were, NOT mask_int, so all host bits are turned on (aka broadcast id), and then the 0xFFFFFFFF keeps it within 32bits rather than 64bits
	
	network=$(int_to_ip "$network_int")
	broadcast=$(int_to_ip "$broadcast_int")

    	declare -a "network_details_$i=('$ip' '$mask' '$network' '$broadcast')"
done

for (( i=0; i<${#raw[@]}; i++ )); do
	details_var="network_details_${i}[@]"
	details=("${!details_var}") #The inside of this is called an "indirect expansion". In order to assign EACH ELEMENT of this array to the elements of the details array, you need to tell bash by the (), which lowkey just means create an array. Without it, you just get a string assigned to details[0]. Same applies to above, but it doesn't need the () because I'm not passing a whole array, I'm just passing a single element.
	echo "IP: ${details[0]}"
	echo "Mask: ${details[1]}"
	echo "Network: ${details[2]}"
	echo -e "Broadcast: ${details[3]}\n"
	
	host_first=$(( network_int + 1 ))
	host_last=$(( broadcast_int - 1 ))
	

done


printf "%s\n" "${raw[@]}"

:<<'note'
I'm just gonna make this a whole note so I don't have another giant comment in the middle of my code. Explanation of xargs: The command itself takes input (normally file/pipe), makes commands from that and then executes them. It's sorta like a bridge between the data itself and the action execution of the code. a.k.a., it takes a list of things and runs a command on each of them. Why do this instead of just running each piece in a loop?... well because it handles long lists, spaces, quotes, etc. including parallelism a lot more safely and nicely. And I want to be able to use this code on big networks if I want, so.... very long lists. 

The flags mean as follows:
-n1 Run command with 1 arg @ a time (aka 1 ip at a time) <--- Don't need this if you run it with -I{} {}
-P50 Run 50 processes in parallel (Might change how many this is later? Probably lol.) When 1 finishes, it'll start another until input is done
-I{} Replaces {} in the command with input
"bash -c 'is_alive "$1" && echo "Alive: $1"'" Runs a new bash process executing the script "is_alive "$1" && echo "Alive: $1"". It then calls my function is_alive, and if it's successful (&&) it'll echo that the host is alive.
& Run them in the background

xargs -P50 -I{} bash -c 'is_alive "$1" && echo "Alive: $1"' {}


note

