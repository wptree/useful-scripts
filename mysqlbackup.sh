#!/bin/sh

if [ $# -lt 1 ];then
	day_count=5
elif [ -z "$1" ] || [[ "$1" == *[!0-9]* ]]; then
	echo "worng input, numeric only."
  	exit -1
else
	day_count=$1
fi

backup_path=/data/backup/mysql
back_end_file=full-bak-$(date +%F --date="$day_count days ago")
delete_list=`ls $backup_path | grep full-bak- | awk '{if($1 < "'$back_end_file'") print $1}'`
for dir in $delete_list
do
	echo "Delete old files: $dir" 
	rm -rf $backup_path/$dir
done

/usr/local/mysql/bin/mysql -uroot -pxposprodroot -e 'flush tables with read lock;'
lvcreate -n mysql-snap -L 1G -s /dev/xpos-vg/mysql-data
/usr/local/mysql/bin/mysql -uroot -pxposprodroot -e 'unlock tables;'
mount /dev/xpos-vg/mysql-snap /tmp/mysql
mkdir -p /data/backup/mysql/full-bak-`date +%F`
cd /tmp/mysql/
tar cf - . | tar xf - -C /data/backup/mysql/full-bak-`date +%F`
cd / 
umount /tmp/mysql
lvremove -f /dev/xpos-vg/mysql-snap


exit $?

