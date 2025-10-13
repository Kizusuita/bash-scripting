#!/usr/bin/env bash

declare -a colors #this is how to declare an array and below is assigning an array
colors=(black brown red orange yellow green blue violet grey white)

if [[ " ${colors[*]} " == *" $1 "* && " ${colors[*]} " == *" $2 "* ]]; then #if anything (*) matches $1/$2 anywhere (**) 
    for (( i=0; i<${#colors[@]}; i++ )); do
        if [[ ${colors[$i]} == "$1" ]]; then #this needs a [[]] because it could break if it's empty if written with just []
            number="${number}${i}" #so this needs to be written like this instead of $number=$number+$i because it's an "expansion" of an already known variable. syntax stuff.
        fi

        if [[ ${colors[$i]} == "$2" ]]; then #adds the second to it
            number2="${number2}${i}"
        fi
    done

    if [[ $number == "0" ]]; then #if first number is a 0, don't print it lol
        echo "$number2"
    else
        echo "${number}${number2}"
    fi
    
else
    echo "invalid color"
    exit 1
fi

