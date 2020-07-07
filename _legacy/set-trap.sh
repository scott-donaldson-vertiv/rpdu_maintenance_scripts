while read -r line
do
	ip=`echo $line | cut -f 1 -d ","`
	umg_ip=`echo $line | cut -f 2 -d ","`
	./set-trap.exp $ip $umg_ip
done < ./set-trap-list.txt
