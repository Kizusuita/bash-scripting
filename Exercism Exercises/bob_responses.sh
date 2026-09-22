#!/usr/bin/env bash

if [[ -z "$1" || "$1" =~ ^[[:space:]]+$ ]]; then
    echo "Fine. Be that way!"
elif [[ "$1" =~ [A-Z] && "$1" == *\? && ! "$1" =~ [a-z] ]]; then
    echo "Calm down, I know what I'm doing!"
elif [[ "$1" =~ [A-Z] && ! "$1" =~ [a-z] ]]; then
    echo "Whoa, chill out!"
elif [[ "$1" =~ \? && ! "$1" == *. ]]; then
    echo "Sure."
else
    echo "Whatever." 
fi
