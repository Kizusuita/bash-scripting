#!/bin/bash

:<< 'Program Information'
usage: ./system_health.sh "check_section"

Program to check various system health, to help diagnose issues if needed or periodic checking for prevention.
Program Information

if [[ -z $# ]]; then
    echo "Usage: ./system_health.sh \"check_section\""
    echo -e "Sections available:\n - cpu (-c | --cpu)\n - disk (-d | --disk)\n - network (-n | --network)\n - services (-s | --services)\n - kernel (-k | --kernel)\n - boot (-b | --boot)"
    exit 1
fi


case "$1" in
    "-c"|"--cpu")
        echo -e "Load Average: $(grep "load average" /var/log/syslog | tail -10)\n"
        echo -e "OOM Events:\n $(grep -i "Out of memory" /var/log/syslog && grep -i "Killed process" /var/log/syslog)\n"
        echo -e "Swap Usage:\n $(grep -i "swap" /var/log/syslog | grep -ie "used\|exhausted")\n"
        echo -e "Hung Tasks:\n $(grep -i "hung task" /var/log/kern.log)\n"
        exit;;
    "-d"|"--disk")
        echo -e "I/O Errors: $(grep -iE "I/O error|bad block" /var/log/syslog)\n"
        if ! grep -i "No space left on device" /var/log/syslog; then
            echo "Disk full?: No"
        else
            echo "Disk full?: *YES* Remedy IMMEDIATELY"
        fi
        echo -e "Mount Errors: $(grep -iE "fs error|mount|umount" /var/log/syslog)\n"
        exit;;
    "-n"|"--network")
        echo -e "Interfaces up/down:\n $(grep -iE "link is up|down" /var/log/syslog)\n"
        echo -e "DHCP/IP Conflict Issues:\n $(grep -i "dhclient" /var/log/syslog | grep -i "error\fail")"
        echo -e "Network Timeouts:\n $(grep -iE "timeout|unreachable|connection refused" /var/log/syslog)\n"
        exit;;
    "-s"|"--services")
        echo -e "Failed Systemd Services:\n $(grep -i "failed to start" /var/log/syslog)\n"
        echo -e "Services Restarted:\n $(grep -i "service" /var/log/syslog | grep -i "restart")\n"
        #If you're using journalctl uncomment next line, it replaces previous :)
        #echo -e "Services Restarted:\n $(journalctl -p err -b | head -10)\n"
        exit;;
    "-k"|"--kernel")
        echo -e "Kernel panic:\n $(grep -i "kernel panic" /var/log/kern.log)\n"
        echo -e "Hardware Errors:\n $(grep -iE "Machine check|hardware error|thermal|overheat" /var/log/kern.log)"
        echo -e "Power Throttling:\n $(grep -i "throttle" /var/log/syslog)"
        exit;;
    "-b"|"--boot")
        echo -e "Recent Boots:\n $(grep "systemd" /var/log/syslog | grep "starting version")\n"
        echo -e "Shutdowns: $(grep -iE "shutdown|poweroff" /var/log/syslog)"
        echo -e "Boot Time Analysis:\n $(systemd-analyze blame | head)"
        exit;;
esac

echo "Section unavailable, did you mistype?"
echo -e "Sections available:\n - cpu (-c | --cpu)\n - disk (-d | --disk)\n - network (-n | --network)\n - services (-s | --services)\n - kernel (-k | --kernel)\n - boot (-b | --boot)"
