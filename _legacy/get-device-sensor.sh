echo -n > get-device-sensor_output.txt
total=0
for i in `cat get-device-sensor-list.txt`
do
        total=`expr $total + 1`
done
current_line=0

for i in `cat get-device-sensor-list.txt`
do
	./get-device-sensor.exp $i > ./sensor-list.txt
	sed -i $'s/[^[:print:]\t]//g' ./sensor-list.txt
	sed -i '/Je/d' ./sensor-list.txt
	sed -i '/cli/d' ./sensor-list.txt
	sed -i '/-------------------/d' ./sensor-list.txt
	sed -i '/^$/d' ./sensor-list.txt
	while read -r line
	do
#		echo "In:"$line
		first=`echo $line | cut -f 1 -d " "`
		if [ $first = "Temperature" ] 
		then
			sensor_type="temperature"
			elif [ $first = "Humidity" ]
			then
				sensor_type="humidity"
			else
				array=`echo $line | cut -c 2`
				id=`echo $line | cut -c 8`
				serial=`echo $line | cut -f2 -d" "`
				echo $i","$sensor_type","$array"."$id","$serial >> get-device-sensor_output.txt
			fi
	done < sensor-list.txt
	current_line=`expr $current_line + 1`
	echo $current_line"/"$total
done
