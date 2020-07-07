echo -n > ./ping_device_output.txt
total=0
for get_line in `cat ping_device_list`
do
        total=`expr $total + 1`
done
current_line=0
responding=0
notresponding=0
for i in `cat ping_device_list`
do
        ping -q -c2 $i > /dev/null
        if [ $? -eq 0 ]
        then
                echo $i",OK" >> ./ping_device_output.txt
		responding=`expr $responding + 1`
	else
		echo $i",no ping" >> ./ping_device_output.txt
		notresponding=`expr $notresponding + 1`
	fi
        current_line=`expr $current_line + 1`
	echo $current_line"/"$total "Responding:"$responding "Not responding:"$notresponding
done
