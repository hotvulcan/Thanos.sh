let i=`find / | wc -l`/2 ; find . | shuf | head -n $i | xargs cat
