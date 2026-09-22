#!/usr/bin/env bash

alpha_low="abcdefghijklmnopqrstuvwxyz"
alpha_up="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
rotation=$2
cipher=""

if [[ $2 -eq 0 || $2 -eq 26 ]]; then
    echo "$1"
else
    cipher=$(echo "$1" | sed "y/${alpha_low}/${alpha_low:$rotation}${alpha_low::$rotation}/") #${variable} = variable, ${variable:start} = print from start position to end, ${variable:start:end} = print from start to end position, ${variable::end} = print from start to end position
#the difference between y/// and s///g is y/// is a character by character subsitution and does the whole string by default. It does NOT take regex. s///g is regex, and matches PHRASES and the g specifically makes it do the whole string. y/// is character translation, and s///g is string substituion.
    
    if [[ "$1" =~ [A-Z] ]]; then
        cipher=$(echo "$cipher" | sed "y/${alpha_up}/${alpha_up:$rotation}${alpha_up::$rotation}/")
        echo "$cipher"
    else
        echo "$cipher"
    fi
fi

