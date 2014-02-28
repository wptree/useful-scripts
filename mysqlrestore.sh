#!/bin/sh

if [ $# -lt 1 ];then
	read -p "target backup data dir: " target
else
	target=$1
fi

if [ ! -d "$target" ]; then
  echo "$target doesn't exist."
  exit -1
fi

echo "Restore Mysql from $target ..."
mkdir -p /data/backup/mysql/broken-bak-`date +%F`
service mysql stop
sleep 3
cd /var/mysql/data
tar cf - . | tar xf - -C /data/backup/mysql/broken-bak-`date +%F`
rm -rf ./*
cd $target
tar cf - . | tar xf - -C /var/mysql/data
chown -R mysql:mysql /var/mysql/data
service mysql start

echo "Mysql restore succeed"

exit $?
