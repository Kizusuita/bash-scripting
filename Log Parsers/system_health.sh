#!/bin/bash

:<< 'Program Information'
usage: ./system_health.sh "check_section"

Program to check various system health, to help diagnose issues if needed or periodic checking for prevention.
Because of the hard coded /var/logs, this script only works on Red Hat based systems. If you'd like, you can change /var/log/messages
to /var/log/syslog for Debian and it'll *probably* work... but no promises.

The -s/--system command uses specfically systemd commands. If you do not use systemd on your system... it's not going to work.
Program Information

if [[ -z $# ]]; then
    echo "Usage: ./system_health.sh \"check_section\""
    echo -e "Sections available:\n - cpu (-c | --cpu)\n - disk (-d | --disk)\n - network (-n | --network)\n - services (-s | --services)\n - kernel (-k | --kernel)\n - boot (-b | --boot)"
    exit 1
fi

system_type=$(grep -E "^ID=" /etc/os-release | sed -E 's/^ID\=//g')

echo -e "Currently Running: $system_type\n-------------------\n"

case "$1" in
    "-c"|"--cpu")
        echo -e "Load Average: $(uptime | awk '{print $NF}')\n"
        echo -e "OOM Events:\n $((dmesg | grep -i "Out of memory") && (dmesg | grep -i "Killed process"))\n"
        echo -e "Swap Usage:\n"

        declare -a mem_usage
        declare -a lines
        mapfile -t mem_usage < <(smemstat -m | sort -n -k 2 | awk '{print $2}' | grep -E '[[:digit:]]')
        mapfile -t lines < <(smemstat -m | sort -n -k 2 | awk '{print $1, $2, $7}' | grep -v "Note")

        for (( i=0; i<${#mem_usage[@]}; i++ )); do
            count=$(bc -l <<< 'scale=3, mem_usage[i]')
            if (( $(echo $count '> 0' | bc -l) )); then
                printf '%s' lines[i]
            fi
        done

        h_tasks=$(dmesg | grep -i "hung task")

        if [[ -z "$h_tasks" ]]; then
            echo -e "Hung Tasks:\n None\n"
        else
            echo -e "Hung Tasks:\n $(h_tasks)\n"
        fi

        exit;;

    "-d"|"--disk")
        echo -e "I/O Errors:\n $(dmesg | grep -i "I/O error")"
        echo -e "Drive Size: $(lsblk | grep -ie 'sda*' | awk '{print $4}' | head -n 1)\n"
        echo -e "Available Space on /home: $(df -h | grep "/home" | awk '{print $4}')\n"

        mount_error=$(grep -iE "fs error|mount|umount" /var/log/messages)

        if [[ -z $mount_error ]]; then
            echo "No Mount Errors"
            exit
        fi

        echo -e "Mount Errors: $mount_error\n"
        exit;;

    "-n"|"--network")
        mapfile -t intface < <(ifconfig | awk '{print $1}' | grep -E "*:" 2> /dev/null | grep -v "lo")
        mapfile -t ipaddr < <(ifconfig | grep "inet" | grep -vE "127.0.0.1|::" | awk '{print $2, $4}')

        echo -e "Interfaces:~#\n------------- "

        for (( i=0; i<${#intface[@]}; i++ )); do
            echo "${intface[i]} ${ipaddr[i]}"
        done

        echo -e "\nDHCP/IP Conflict Issues:\n $(grep -i "dhclient" /var/log/messages | grep -iE "error|fail")"
        echo -e "Network Timeouts:\n $(grep -iE "timeout|unreachable|connection refused" /var/log/messages)\n"
        exit;;

    "-s"|"--services")
        echo -e "Services Started: $(systemctl list-units --type=service --state=active | tail -n 1)\n"
        echo -e "Failed Systemd Services: $(systemctl list-units --type=service --state=failed | tail -n 1)\n"
        exit;;

    "-k"|"--kernel")
        echo -e "kdump active?: $(systemctl status kdump | grep "Active:" | sed 's/^[[:space:]]*//g')\n\n----------------------\n"
        echo -e "Hardware Errors:\n$(grep -iE "Machine check|hardware error|thermal|overheat" /var/log/messages)\n"
        echo -e "Unknown Hardware:~#\n----------------------\n$(hwinfo --short | awk '/unknown/{flag=1;next} flag' | sed 's/^[[:space:]]*//g')\n"
        echo -e "Power Throttling:\n $(grep -i "throttle" /var/log/messages)"
        exit;;

    "-b"|"--boot")
        time=$(last reboot shutdown | tail -n 1 | cut -d " " -f3-7)

        echo -e "$(journalctl -b | head -n 2 | awk '{print $6, $7, $8, $36}')\n"
        echo -e "User Shutdowns (from $time): $(last reboot shutdown | wc -l)\n"
        echo -e "Time Intensive Boot Processes:~#\n--------------------------------\n$(systemd-analyze blame | head -n 5)"
        exit;;

esac

echo "Section unavailable, did you mistype?"
echo -e "Sections available:\n - cpu (-c | --cpu)\n - disk (-d | --disk)\n - network (-n | --network)\n - services (-s | --services)\n - kernel (-k | --kernel)\n - boot (-b | --boot)"
