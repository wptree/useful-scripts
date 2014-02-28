#!/bin/sh

DBName="sdbbiz"
DBUser="root"  
DBPasswd="sdbapproot"
BackupPath="/var/backup/mysql"  
CurrentPath=$(pwd)
CompressPasswd="1qazZSE$"

#ftp server
ftphost=183.129.159.194
ftpport=2111
un="backup"
pw="'PrZ8vm3dmAMPCQp3MDW"
remotedir="/array1/backup" 
  
DumpFile=sdbbiz_$(date +%Y_%m_%d).sql  
NewFile=sdbbiz_$(date +%Y_%m_%d).tar.gz 

OldFile=$BackupPath/sdbbiz_$(date +%Y_%m_%d --date='30 days ago').tar.gz 
OldFileInFtp=$remotedir/sdbbiz_$(date +%Y_%m_%d --date='30 days ago').tar.gz
 
  
#create backup directory
if [ ! -d $BackupPath ]; then  
    mkdir $BackupPath  
fi  
  
echo "---------------------------------------------------------------------"
echo $(date +"%y-%m-%d %H:%M:%S")  
echo "---------------------------------------------------------------------"  
  
#remove history file
if [ -f $OldFile ]; then  
  rm -f $OldFile
  echo "[$OldFile] Delete Old File Success!" 
fi  
  
#new file
if [ -f $BackupPath/$NewFile ]; then  
    echo "[$NewFile] The Backup File exists,Can't Backup! "
else  
    /usr/local/mysql/bin/mysqldump --opt -u$DBUser -p$DBPasswd $DBName > $BackupPath/$DumpFile
    cd $BackupPath
    #tar czvf $NewFile $DumpFile
	tar -zcvf - $DumpFile|openssl des3 -salt -k $CompressPasswd | dd of=$NewFile
    rm -rf $DumpFile
    echo "[$NewFile] Backup $DBName Success!"

    #backup to ftp --port 2111
    ftp -nvp $ftphost $ftpport <<EOF 
    user $un $pw
    binary
    cd $remotedir
    #remove history file in ftp
    delete  $OldFileInFtp
    put $NewFile
    bye	
EOF
    echo "[$NewFile] Backup To Ftp Server Success"
    cd $CurrentPath
fi  

exit $?
