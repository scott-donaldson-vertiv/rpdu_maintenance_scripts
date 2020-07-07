for i in `cat ./set-community-list.txt`
do
	./set-community.exp $i
done
