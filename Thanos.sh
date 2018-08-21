#!/bin/sh
let i=`find . -type f | wc -l`/2 ; find . -type f -print0 | shuf -z -n $i | xargs -0 -- cat 
