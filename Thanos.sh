#!/bin/sh
let "i=`find . -type f | wc -l`/2";
if [[ uname=="Darwin" ]]; then
    find . -not -name "Thanos.sh" -type f -print0 | gshuf -z -n $i | xargs -0  -- cat;
else
    find . -not -name "Thanos.sh" -type f -print0 | shuf -z -n $i | xargs -0  -- cat;
fi
# Explanation
## Step 1: Get the count of files in current path divided by two.
## Step 2: Get all the files in current path and print in one line.
## Step 3: Turn half of the second step output into standard input randomly.
## Step 4: Show half of the files in terminal.

# Key Point
## If you want to make delete, what you need to do is turn 'cat' into 'rm'.
