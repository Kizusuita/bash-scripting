#!/usr/bin/env bash

str="$1"

if [ "$str" == "" ]; then #The spaces before and after the argument are REQUIRED. It messes with your code if you don't.
    echo "One for you, one for me."
else
    echo "One for $str, one for me."
fi