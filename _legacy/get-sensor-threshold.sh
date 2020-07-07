echo -n > ./get-sensor-threshold-output.txt
total=0
for get_line in `cat ./get-sensor-threshold-list.txt`
do
        total=`expr $total + 1`
done
current_line=0
for i in `cat ./get-sensor-threshold-list.txt`
do
	./get-sensor-threshold.exp $i > ./sensor-threshold.txt
        sed -i $'s/[^[:print:]\t]//g' ./sensor-threshold.txt
        sed -i '/Je/d' ./sensor-threshold.txt
        sed -i '/cli/d' ./sensor-threshold.txt
        sed -i '/-------------------/d' ./sensor-threshold.txt
        sed -i '/^$/d' ./sensor-threshold.txt
	while read -r line
        do
#               echo "In:"$line
                first=`echo $line | cut -f 1 -d " "`
                if [ $first = "Temperature" ]
                then
                        sensor_type="Temperature"
                        elif [ $first = "Humidity" ]
                        then
                                sensor_type="Humidity"
                        else
                                array=`echo $line | cut -c 2`
                                id=`echo $line | cut -c 8`
				high_critical=`echo $line | cut -c 12-15`
				high_warning=`echo $line | cut -c 19-22`
				low_critical=`echo $line | cut -c 26-29`
				low_warning=`echo $line | cut -c 33-36`
                                echo $i","$sensor_type","$array"."$id","$high_critical","$high_warning","$low_critical","$low_warning >> ./get-sensor-threshold-output.txt
                       fi
        done < sensor-threshold.txt
	current_line=`expr $current_line + 1`
	echo $current_line"/"$total
done
