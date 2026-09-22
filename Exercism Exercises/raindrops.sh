#!/usr/bin/env bash

number=$1
rain=""

if [ $((number%3)) -eq 0 ]; then
    rain+="Pling"
fi

if [ $((number%5)) -eq 0 ]; then
    rain+="Plang"
fi

if [ $((number%7)) -eq 0 ]; then
    rain+="Plong"
fi
    
### ^^^ These have to be separate if-statements because elif OVERWRITES, doesn't append.
                        #Also vv The -z doesn't need a = of any kind. Just put before string.
if [ -z "$rain" ]; then #Making it clear for myself, STRINGS use typical operators, INTEGERS use the -whatever for comparison.
    echo "$number"
else
    echo "$rain"
fi

