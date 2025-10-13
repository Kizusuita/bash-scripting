#!/usr/bin/env bash

#I don't think anyone will ever read this, but I'm really proud. I'm finally starting to be able to write scripts with just remembering and not looking up guides. I wrote this without looking up any help :)

square_of(){

    sum=0
    square=0
        
    for (( i=1; i<="$1"; i++ )); do
        sum=$(( sum+i ))
    done

    square=$(( sum*sum ))

    echo "$square"

}

sum_of(){

    sum=0
        
    for (( i=1; i<="$1"; i++ )); do
        sum=$(( sum+(i*i) ))
    done

    echo "$sum"
    
}

case "$1" in
    square_of_sum)
        square_of "$2"
    ;;
    sum_of_squares)
        sum_of "$2"
    ;;
    difference)
        sum=$(square_of "$2")
        sum2=$(sum_of "$2")
        
        difference=$(( sum-sum2 ))

        echo "$difference"
    ;;
esac

