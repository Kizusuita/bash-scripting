#!/usr/bin/env bash

declare -a colors
colors=(black brown red orange yellow green blue violet grey white)
num_string=""
final_num=0

if [[ (! ${colors[*]} =~ $1) || (! ${colors[*]} =~ $2) || (! ${colors[*]} =~ $3)]]; then
    echo "Invalid color input"
    exit 1
fi

for (( i=0;i<${#colors[@]}; i++ )); do
    if [[ "$1" == "${colors[i]}" ]]; then
        num_string="$i$num_string"
    fi

    if [[ "$2" == "${colors[i]}" ]]; then
        num_string="$num_string$i"
    fi
done

if [[ "$1" == "black" ]]; then
    num_string=${num_string:1} #take out leading 0
fi

for (( i=0;i<${#colors[@]}; i++ )); do
    if [[ "$3" == "${colors[i]}" ]]; then
        final_num=$((num_string*(10**i))) #exponent!
    fi
done

if (( final_num == 0 )); then
    echo "$final_num ohms"
elif (( final_num % 1000000000 == 0 && final_num >= 1000000000 )); then 
    echo "$(( final_num / 1000000000 )) gigaohms"
elif (( final_num % 1000000 == 0 && final_num >= 1000000 )); then
    echo "$(( final_num / 1000000 )) megaohms"
elif (( final_num % 1000 == 0 && final_num >= 1000 )); then #i'm checking the mod to make sure there isn't decimals like the 1.2 kiloohms ><
    echo "$(( final_num / 1000 )) kiloohms"
else
    echo "$final_num ohms"
fi





