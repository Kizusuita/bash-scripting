#!/usr/bin/env bash

declare -a colors
colors=( "black" "brown" "red" "orange" "yellow" "green" "blue" "violet" "grey" "white" )

case "$1" in #This is a switch statement in Bash. The syntax is case $variable in, followed by ) and end each with ;;
    colors)
        for color in "${colors[@]}"; do
            echo "$color"
        done
        
        ;;
    code)
        for ((i=0; i<${#colors[@]}; i++)); do
            if [[ "$2" == "${colors[$i]}" ]]; then
                echo "$i"
            fi
        done
        
        ;;
esac
    
