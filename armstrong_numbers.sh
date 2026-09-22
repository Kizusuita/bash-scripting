#!/usr/bin/env bash

num=$1
added=0

#do math
for (( i=${#num}-1; i>=0; i-- )); do
  digit="${num:i:1}" # extract one digit
  cube=$(bc <<< "$digit^${#num}") # cube it using bc
  added=$(bc <<< "$added + $cube") # add it together
done

#check if same
if [ "$num" -lt "10" ]; then #fun fact, don't use the symbols lol, it's -lt for less than
    echo "true" #bc all single digits are armstrong
elif [ "$added" = "$num" ]; then
    echo "true"
else
    echo "false"
fi