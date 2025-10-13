#!/usr/bin/env bash

if (( "$1" <= 0 )); then
    echo "Classification is only possible for natural numbers."
    exit 1
else
    ali=0

    for (( i=1; i*i<="$1"; i++ )); do #I'm trying to remember and I keep messing it up, [] = STRINGS () = INTEGERS
        if (( "$1" % i == 0 )); then
            j=$(( "$1" / i ))

            if (( i != "$1" )); then
                ali=$(( ali + i ))
            fi
            
            if (( j != i && j != "$1" )); then
                ali=$(( ali + j ))
            fi
        fi
    done
fi

if [[ "$1" -lt 0 ]]; then
    echo "Classification is only possible for natural numbers."
elif [[ "$1" == "$ali" ]]; then #then compare, if equal then perfect
    echo "perfect"
elif [[ "$1" -gt "$ali" ]]; then #og greater = def
    echo "deficient"
elif [[ "$1" -lt "$ali" ]]; then #og less = abundant
    echo "abundant"
fi

: <<'EOF'
I found out how to comment block in bash, so when I'm debugging I can comment out big blocks without have to individually type #'s. You start it with : << 'delimiter' and then just end it with delimiter

Speaking of, the above I had to modify. My original code WORKED but it was like insane computing power because I was just incrementing by 1 for the whole number, which for big numbers just... doesn't work. So I asked for help and found out that I can use sqrt, or squares to cut down. The for loop runs i*i so it squares i, and then i divide $1 by i in the loop so I can checked 2 factors at once, both factor1 * factor2 and factor2 * factor1. But I don't wanna add these numbers twice, so the if statements following I use to check and make sure I'm not adding j (factor1) twice, because I'm already adding i (factor2) above. It cuts computation power insanely, making the code allowed to run. End of speech haha
EOF
