#!/usr/bin/env bash

acronym=""
IFS=' ' #Set the delimiter for array splitting

clean_word=$(echo "$1" | sed -E "s/[^a-zA-Z0-9']+/ /g") #Here's another long explanation lol. -E makes it a regex, just meaning you don't have to use escape sequences in this case. The syntax for a sed cmd is s/<PATTERN>/<REPLACEMENT>/g for subsituting globally. s = sub, g = global (all). The ^ means anything *not* listed in the pattern you want to get rid of. the patterns are just the letters/numbers/symbols you want. I wanted to keep ', a-z, A-Z, so that is what is listed. Then the + means one OR MORE of those kept, so it just keeps all of them, only getting rid of the special escape characters. And I used a space as a replacement so the array would just split at the spaces.

read -ra array <<< "$clean_word" #Split the string into an array, -a is naming it, declaring the array's name in as "array" bc it's -a array, the read is reading in from "<<< "$1"".

for element in "${array[@]}"; do
    acronym+=${element:0:1}
done

echo "${acronym^^}" #{^^} makes all letters capital