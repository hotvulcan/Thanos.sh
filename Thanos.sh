#!/bin/sh

filename=${0##*/}
rm_dir="./temp"

function touch_file()
{
    if [[ ! -d ${rm_dir} ]]; then
        mkdir -p ${rm_dir}
    fi

    cnt=10
    while [[ cnt -gt 0 ]];
    do
        touch ${rm_dir}/${cnt}.txt
        let cnt-=1
    done
}

function rm_files()
{
    sf="shuf"
    if [[ "`uname`" == "Darwin" ]]; then
        sf="gshuf"
    fi

    files=()
    while read line;
    do
        files+=("${line}")
    done <<< "`find ${rm_dir} -not -name "${filename}" -type f`"

    let nums=${#files[*]}/2
    echo ${files[*]} | xargs printf "%s\0" | ${sf} -z -n ${nums} | xargs -0 -- sudo rm -f
    echo "nums: ${nums}"
}

touch_file
rm_files

# Explanation
## Step 1: Get the count of files in current path divided by two.
## Step 2: Get all the files in current path and print in one line.
## Step 3: Turn half of the second step output into standard input randomly.
