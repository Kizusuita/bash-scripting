#!/usr/bin/env bash

point_10=$(echo "(sqrt(($1^2)+($2^2))) <= 1" | bc -l ) #This thing is a pain lol, you can't put it directly in the if statement because you need the $() and you CAN'T put $() into (()) because $() makes it a string and (()) only handles arithmetic. Also, bc only returns 0 or 1, 1 if true and 0 if false. For future reference lol.
point_5=$(echo "(sqrt(($1^2)+($2^2))) <= 5" | bc -l )
point_1=$(echo "(sqrt(($1^2)+($2^2))) <= 10" | bc -l )
points=0

if [[ -z "$1" || -z "$2" ]]; then #It breaks the regex if I don't check for empty strings first
    echo " "
    exit 1
elif [[ (! "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ) || (! "$2" =~ ^-?[0-9]+(\.[0-9]+)?$ ) ]]; then #This is how you check if a number is POSITIVE OR NEGATIVE /and/ accounts for decimals for the floats. The thing I was missing was the -? to check for negative or positive
    echo " "
    exit 1
else
    if (( $point_10 == 1 )); then
        points=$((points+10))
    elif (( $point_5 == 1 )); then
        points=$((points+5))
    elif (( $point_1 == 1 )); then
        points=$((points+1))
    else
        points=$((points+0))
    fi
fi

echo "$points"


