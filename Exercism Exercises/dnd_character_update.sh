#!/usr/bin/env bash

modifier(){

    if [[ "$1" =~ ^-?[0-9]+$ ]]; then
        if [[ $1 -ge 10 ]]; then
            mod=$(( ($1 - 10) / 2 ))
        else
            mod=$(( ($1 - 11) / 2 ))
        fi
    fi

    echo "$mod"

}

generate(){

    declare -a dice_rolls
    declare -a ability

    for (( j=0; j<4; j++ )); do
        dice_rolls[j]=$(( (RANDOM % 6) + 1 ))
    done

    mapfile -t ability < <(printf "%s\n" "${dice_rolls[@]}" | sort -nr) #takes input and makes it into an array by splitting each word/line. the print i did printed each element and did it on a new line, and then sorted it so i could just add the first three

    echo "$(( ability[0] + ability[1] + ability[2] ))"
}



case "$1" in
    modifier)
        modifier "$2"
    ;;

    generate)
        cons=$(generate)
        cons_mod=$( modifier "$cons" )
        hitpoints=$(( cons_mod + 10 ))

        echo "strength $(generate)"
        echo "dexterity $(generate)"
        echo "constitution $cons"
        echo "intelligence $(generate)"
        echo "wisdom $(generate)"
        echo "charisma $(generate)"
        echo "hitpoints $hitpoints"
    ;;
esac
