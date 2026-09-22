#!/usr/bin/env bash

points=0
declare -a letters

for (( i=0; i<${#1}; i++ )); do #put each letter into an index
    letters[i]=${1:i:1}
done

for letters in "${letters[@]}"; do #interate thru all letters and then match them :)
    case "${letters,,}" in
        a|e|i|o|u|l|n|r|s|t)
            points=$(($points+1))
            ;;
        d|g)
            points=$(($points+2))
            ;;
        b|c|m|p)
            points=$(($points+3))
            ;;
        f|h|v|w|y)
            points=$(($points+4))
            ;;
        k)
            points=$(($points+5))
            ;;
        j|x)
            points=$(($points+8))
            ;;
        q|z)
            points=$(($points+10))
            ;;
    esac
done

echo "$points"