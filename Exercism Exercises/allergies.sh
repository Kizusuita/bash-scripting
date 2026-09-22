#!/usr/bin/env bash

#0 0 0 0 0 0 0 0
#egg peanuts shellfish strawberries tomatoes chocolate pollen cats

declare -a allergen
declare -a allergies
allergen=(eggs peanuts shellfish strawberries tomatoes chocolate pollen cats)

case "$2" in
    allergic_to)
        for (( i=0; i<${#allergen[@]}; i++ )); do #for len of array
            if [[ "${allergen[i]}" == "$3" ]]; then #if $3 = allergen then
                if (( $(( $1 & (1 << i) )) )); then #God bless the person on Discord who taught me how to do this, extremely patiently.
                    echo "true" #if bit is on, true
                else
                    echo "false"
                fi
                exit #after check, exit
            fi
        done

        echo "false"
        exit
    ;;

    list)
        for (( i=0; i<${#allergen[@]}; i++ )); do 
            if (( $(( $1 & (1 << i) )) != 0 )); then
                allergies+=("${allergen[i]}")
            fi
        done

        echo "${allergies[*]}"
    ;;
esac








