#!/usr/bin/env bash

if [[  ($1 =~ ^[ACGT]+$) || (-z $1) ]]; then
    a_count=$(echo "$1" | sed -E 's/[CGT]+//g')
    a_len=${#a_count}
    
    c_count=$(echo "$1" | sed -E 's/[AGT]+//g')
    c_len=${#c_count}
    
    g_count=$(echo "$1" | sed -E 's/[ACT]+//g')
    g_len=${#g_count}
    
    t_count=$(echo "$1" | sed -E 's/[ACG]+//g')
    t_len=${#t_count}

    echo -e "A: $a_len\nC: $c_len\nG: $g_len\nT: $t_len" #need -e because of the escape characters. doesn't recognize them otherwise
else
    echo "Invalid nucleotide in strand"
    exit 1
fi
