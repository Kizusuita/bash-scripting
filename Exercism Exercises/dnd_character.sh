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
    declare -a abilities
    
    ability=0
    
    for (( e=0; e<6; e++ )); do
        dice_rolls=()
        
        for (( j=0; j<4; j++ )); do
            dice_rolls[j]=$(( (RANDOM % 6) + 1 ))
        done

        sorted=($(printf "%s\n" "${dice_rolls[@]}" | sort -nr)) #time to learn something new! printf helps print stuff. the "%s\n" means print this string variable (%s) (variable listed after i.e. "dice_rolls") on a new line (\n), and it expanded the array dice_rolls. it'll then /sort/ by numeric order (-n) in the reverse (-r)

        ability=$(( sorted[0] + sorted[1] + sorted[2] ))

        abilities[e]=$ability
    done

    cons_mod=$( modifier "${abilities[2]}" )
    hitpoints=$(( cons_mod + 10 ))

    echo "strength ${abilities[0]}"
    echo "dexterity ${abilities[1]}"
    echo "constitution ${abilities[2]}"
    echo "intelligence ${abilities[3]}"
    echo "wisdom ${abilities[4]}"
    echo "charisma ${abilities[5]}"
    echo "hitpoints $hitpoints"
    
}



case "$1" in
    modifier)
        modifier $2
    ;;

    generate)
        generate
    ;;
esac
