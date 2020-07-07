#! /bin/sh
for i in  `cat ./pdu_list`
do
    echo $i
	./mph_sensor_devicechange.sh $i
done
