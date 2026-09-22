#!/usr/bin/env bash

DNA="$1"
RNA=""

for (( i=0; i<${#DNA}; i++ )); do #Also, this isn't a set order like I thought. BASH works like C, and instead of it like Java    where the for-loop doesn't really swap around, this it does. In reverse, the i<{$DNA} is first, where in forwards it is second. This is because (( init; condition; step )); is the actual syntax of this. Initially, i is 0. You then want to check after i has increased, rather than before like subtraction. 
    nucleotide="${DNA:i:1}"
    if [ "$nucleotide" = "G" ]; then
        complement="C"
    elif [ "$nucleotide" = "C" ]; then
        complement="G"
    elif [ "$nucleotide" = "T" ]; then
        complement="A"
    elif [ "$nucleotide" = "A" ]; then
        complement="U"
    else
        echo "Invalid nucleotide detected."
        exit 1 #so the 1 here is what is called an "assertation". it actually returns "failed" basically, telling the shell there                   was an error
    fi
    RNA="$RNA$complement" #And this will concat all the letters together
done

echo $RNA