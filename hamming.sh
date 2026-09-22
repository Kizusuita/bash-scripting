#!/usr/bin/env bash

if [[ "$#" -ne 2 ]]; then
    echo "Usage: hamming.sh <string1> <string2>"
    exit 1
fi

str1="$1"
str2="$2"

if [[ ${#str1} -ne ${#str2} ]]; then
    echo "strands must be of equal length"
    exit 1
fi

diff=0
for (( i=0; i<${#str1}; i++ )); do
    if [[ "${str1:$i:1}" != "${str2:$i:1}" ]]; then #This is what I was trying to do with my previous, but extremely failed.
        ((diff++))
    fi
done

echo "$diff"

:<<'note'
Queue me trying to overcomplicate everything, orginally I was making an array and piping it into grep to match individual letters lol. It's fine, this is so much simplier, I knew I was overcomplicating it. 
note
