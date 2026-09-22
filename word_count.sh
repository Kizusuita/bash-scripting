#!/usr/bin/env bash

declare -a words
                                                                        
mapfile -d ' ' -t words < <( echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E "s/([^a-zA-Z0-9'])/ /g") #mapfile maps input into an array using a delimiter. I set mine with -d for the spaces in the sentence. tr = translate (don't have to worry about upper v lower letters), then sed

for i in "${!words[@]}"; do
    words[$i]=$(sed "s/^'//; s/'$//" <<< "${words[$i]}") #it's the character sub again, sub out the beginning ' (^') and the end ('$) if it has it, looped over every word in the array :)
done

echo "${words[@]}" | tr ' ' '\n' | grep -v '^$' | sort | uniq -c | while read -r count word; do #the grep -v in this case is giving everything that ISN'T just a space, so it gives the sort every line that isn't just a new line, uniq -c is done after the sort because sort has now made all the lines in alphabetical order, and uniq -c will "collapse" all words that are similar AND ADJACENT (thats why you need the sort first) and count how many of each there was. and the while read count word does take the output of uniq and "read" it into the while loop. Essentially it's "while there's words to read into this from uniq, do", and it's just assigning variable names to the 2 outputs of uniq (the count and the word.) I could make "count" and "word" be anything and it would still work, but relating names is better :) (also the -r just makes it not eat backslashes, which isn't bad in this case but just get in the habit of always using read -r)
    echo "$word: $count"
done


