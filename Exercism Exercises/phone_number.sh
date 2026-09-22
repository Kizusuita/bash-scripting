#!/usr/bin/env bash

number=$(echo "$1" | sed 's/[[:punct:][:space:]]//g') #OMG There's things called characters classes, [:punct:] is ALL punctuation, and [:alnum:] is ALL letters and numbers. Literally game-changer

if [[ ${#number} -eq 11 && ${number:0:1} == 1 ]]; then
    core="${number:1}"   #takes out the leading 1 if 11 digits AND starts with 1
elif [[ ${#number} -eq 10 ]]; then
    core="$number"
else
    echo "Invalid number.  [1]NXX-NXX-XXXX N=2-9, X=0-9"
    exit 1
fi

if [[ ${core:0:1} =~ [2-9] && ${core:3:1} =~ [2-9] ]]; then #this will check if area code OR exchange is above 0 or 1
    echo "$core"
else
    echo "Invalid number.  [1]NXX-NXX-XXXX N=2-9, X=0-9"
    exit 1
fi


