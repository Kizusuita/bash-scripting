#!/usr/bin/env bash

letters=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z' | fold -w1 | sort -u | wc -l)

#Another long paragraph lol, tr is "transform". It's gonna make all :upper: into :lower: first. Then it's going to -c "compliment" the set, aka gonna find the "a-z" that I declared with it. Then -d "delete" anything that isn't those. Just another way for the sed so far right? Then "fold" means it's gonna split it up into columns, with a -w1 "width" of 1, 1 character. The "sort -u" sorts it alphabetically, and finally the "wc -l" actually counts the lines. wc is "word count" and the -l is the number of lines.

if [ "$letters" -eq 26 ]; then
    echo "true"
else
    echo "false"
fi


