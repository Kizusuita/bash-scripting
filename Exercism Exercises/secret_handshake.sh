#!/usr/bin/env bash

declare -a handshake
declare -a order
declare -a reversed
handshake=("wink" "double blink" "close your eyes" "jump" "reverse")

for (( i=0; i<${#handshake[@]}; i++ )); do 
    if (( $(( $1 & (1 << i) )) != 0 )); then
        order+=("${handshake[i]}")
    fi
done

last_index=$(( ${#order[@]} - 1 ))
if [[ ($last_index -ge 0) && ("${order[last_index]}" == "reverse") ]]; then
    unset 'order[-1]' #-1 is last index in array

    for (( i=${#order[@]}-1 ; i>=0 ; i-- )); do
        reversed+=("${order[i]}")
    done

    string=$(printf "%s," "${reversed[@]}")
    echo -n "${string::-1}"
else
    string=$(printf "%s," "${order[@]}")
    echo -n "${string::-1}"
fi




