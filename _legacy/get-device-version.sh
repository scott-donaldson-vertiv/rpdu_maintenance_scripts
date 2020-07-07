echo -n > ./get-device-version-output.txt
total=0
for get_line in `cat ./target_list.txt`
do
        total=`expr $total + 1`
done
current_line=0
for i in `cat target_list.txt`
do
	./get-device-version.exp $i > ./device-version.txt
	echo $i","`cat ./device-version.txt | grep "app version" | cut -f 2 -d ":" | cut -c 2-` >> ./get-device-version-output.txt 
	current_line=`expr $current_line + 1`
	echo $current_line"/"$total
done
