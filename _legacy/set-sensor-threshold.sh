echo -n > ./set-sensor-threshold-output.txt
total=0
for ip in  `cat ./set-sensor-threshold-ip-list.txt`
do
        total=`expr $total + 1`
done

current_line=0

for ip in `cat ./set-sensor-threshold-ip-list.txt`
do
	cat ./set-sensor-threshold-login.exp > ./set-sensor-threshold.exp
	search_ip=$ip","
	grep $search_ip ./set-sensor-threshold-list.txt > ./set-sensor-threshold-list-tmp.txt
	while read -r line
	do
		sensor_type=`echo $line | cut -f 2 -d ","`
		sensor_id=`echo $line | cut -f 3 -d ","`
		thresholds=`echo $line | cut -f 4 -d ","`	
		echo "send \"sensor threshold" $sensor_type $sensor_id $thresholds\\r\" >> ./set-sensor-threshold.exp
		echo "expect \"cli-> \""  >> ./set-sensor-threshold.exp
	done < ./set-sensor-threshold-list-tmp.txt 
	echo "send \"exit\\r\"" >> ./set-sensor-threshold.exp
	echo "expect eof" >> ./set-sensor-threshold.exp
	
	chmod +x ./set-sensor-threshold.exp
	./set-sensor-threshold.exp $ip
	current_line=`expr $current_line + 1`
	echo $current_line"/"$total
done
