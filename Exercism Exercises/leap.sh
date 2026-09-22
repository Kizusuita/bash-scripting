#!/usr/bin/env bash

if [[ "$1" =~ ^-?[0-9]+$ ]]; then # vv oh yeah and the =~ means regex. that's what tells bash it's a regular expression.
    if [[ "$1" =~ ^[-+]?[0-9]*\.[0-9]+$ ]]; then #Alright lol, this is a long one. This are *regular expressions* the things you'd plug into egrep ? Yeah those. The first thing [^] is called an anchor. Anytime you start a regular expression, you need one. Then the [-+]? is a unit. It's called an optional sign. This is where you specify if you want a +, - or nothing leading the number. The ? says "zero or one" of the integers present. No more than 1. There's 2 others you can put here, (* → zero or more), and (+ → one or more). Then "." is all by itself, just means any character, the \ is just an escape sequence. The "[0-9]+" or the "[0-9]*" means any number between 0-9 and the sign at the end is a "quantifier" meaning how many. The + means one or more and the * means maybe none, maybe many, just like above. And FINALLY the $ just means the end. Again, need it at the end of every regex.
        echo "Usage: leap.sh <year>"
        exit 1
    elif [ -z "$1" ]; then
        echo "Usage: leap.sh <year>"
        exit 1
    elif [ $# -ne 1 ]; then
        echo "Usage: leap.sh <year>"
        exit 1
    elif [[ $(($1%100)) -eq 0 ]] && [[ $(($1%400)) -ne 0 ]]; then #Need double brackets because of the &&, also needed with or (||), also each expression needs its own [[]]
        echo "false"
    elif [ $(($1%4)) -eq 0 ]; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "Usage: leap.sh <year>"
    exit 1
fi




