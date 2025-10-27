#!/bin/bash

:<< 'Program information'
Summarizes authentication activity from Red H
By default I have made it the top 10 results for each, but feel free to change the "fields" variable to change this setting.

Usage: ./auth_audit.sh
Program information

log_file="/var/log/secure"
fields="10"

if [[ ! -f "$log_file" ]]; then
    echo "Log file not found: $log_file" >&2 #Redirect errors
    exit 1
fi

echo "===== AUTHENTICATION AUDIT ====="
echo "Source: $log_file"
echo "Date: $(date -u +'%F %T')"
echo ""

echo -e "Failed login attempts: $(grep "authentication failure" "$log_file" | wc -l)\n"

echo -e "Top users with failed logins:\n$(grep "check failed" "$log_file" | awk '{print $(NF)}' | sort | uniq -c)\n"

echo -e "Successful SSH logins:\n$(grep "LOGIN ON" "$log_file" | tail "-$fields")\n"

echo -e "Last successful root login:\n$(grep "ROOT LOGIN" "$log_file" | tail -1)\n"

if [[ $(grep "ROOT LOGIN" "$log_file") == "" ]]; then
    echo "No root login found."
fi

echo -e "Failed sudo attempts: $(grep "sudo" "$log_file" | grep "incorrect password" | wc -l)\n"
echo -e "User | Command Preformed:\n$(grep "sudo" "$log_file" | grep "incorrect password" | awk '{print $6 $(NF)}' | sed 's/COMMAND=/ | /g' )"
echo ""
echo "=========================================="
