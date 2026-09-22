#!/usr/bin/env bash

grains=0
total=0

if [ "$1" = "total" ]; then  #total grains
    for (( i=1; i<=64; i++ )); do
        grains=$(bc <<< "2^($i - 1)")
        total=$(bc <<< "$total + $grains")
    done
    echo "$total"
    
elif [ "$1" -gt "64" ]; then #if param greater than 64
    echo "Error: invalid input"
    exit 1 #gives the assert_failure
    
elif [ "$1" -lt "1" ]; then #if param less than 1
    echo "Error: invalid input"
    exit 1 #gives the assert_failure
    
else
    echo "2^($1 - 1)" | bc #everything else
    
fi