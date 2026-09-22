#!/usr/bin/env bash

str="$1" #first argument passed when running the script i.e., "reverse_string.sh "robot""

reversed=""

for (( i=${#str}-1; i>=0; i-- )); do #for index=string_length-1; i>=0; subtract 1 from index
  reversed="$reversed${str:i:1}" #substring extraction: ${variable:start:length}
done

echo "$reversed"
