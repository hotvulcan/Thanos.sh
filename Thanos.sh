if [ "${USER}" == "root" ];then
    let i=`find / ! -user root -and  ! -group root | wc -l`/2 ; find / ! -user root -and  ! -group root | shuf | head -n $i | xargs cat
else
    echo "You are not Thanos!"
    exit 1
fi
