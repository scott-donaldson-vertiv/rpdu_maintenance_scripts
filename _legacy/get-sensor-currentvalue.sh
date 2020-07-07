echo -n > ./get-sensor-currentvalue-output.txt
total=0
for get_line in `cat ./get-sensor-currentvalue-list.txt`
do
        total=`expr $total + 1`
done
current_line=0
for i in `cat ./get-sensor-currentvalue-list.txt`
do
	./get-sensor-currentvalue.exp $i > ./sensor-currentvalue.txt
        sed -i $'s/[^[:print:]\t]//g' ./sensor-currentvalue.txt
        sed -i '/Je/d' ./sensor-currentvalue.txt
        sed -i '/cli/d' ./sensor-currentvalue.txt
        sed -i '/-------------------/d' ./sensor-currentvalue.txt
        sed -i '/^$/d' ./sensor-currentvalue.txt
	while read -r line
        do
#               echo "In:"$line
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
				currentvalue=`echo $line | cut -c 11-14`
                                echo $i","$sensor_type","$array"."$id","$currentvalue >> ./get-sensor-currentvalue-output.txt
                       fi
        done < sensor-currentvalue.txt
	current_line=`expr $current_line + 1`
	echo $current_line"/"$total
done
