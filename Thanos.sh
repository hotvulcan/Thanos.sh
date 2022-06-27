#!/usr/bin/env bash

filename=${0##*/}
rm_dir="./temp"

touch_file() {
    if [[ ! -d ${rm_dir} ]]; then
        mkdir -p ${rm_dir}
    fi

    cnt=10
    while [[ $cnt -gt 0 ]]; do
        touch ${rm_dir}/${cnt}.txt
        cnt=$((cnt - 1))
    done
}

rm_files() {
    sf="shuf"
    if [ "$(uname)" = "Darwin" ]; then
        sf="gshuf"
    fi

    files=()
    while read -r line; do
        files+=("${line}")
    done <<<"$(find ${rm_dir} -not -name "${filename}" -type f)"

    let nums=${#files[*]}/2
    echo "${files[*]}" | xargs printf "%s\0" | ${sf} -z -n ${nums} | awk "{print \"xargs -0 -- sudo rm -f \" \$0}"
    echo "nums: ${nums}"
}

touch_file
rm_files

# Explanation
## Step 1: Get the count of files in current path divided by two.
## Step 2: Get all the files in current path and print in one line.
## Step 3: Turn half of the second step output into standard input randomly.
