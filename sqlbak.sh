#!/bin/bash

#Working Values
database=$1
workingdir=/tmp/sqlbak
configdir=/etc/mysql-backup
backupdir=/backup
DATE=`date +%Y-%m-%d:%H:%M:%S`
keydir=${configdir}/keys
privkey=${keydir}/.private/private_key.pem
mysqluserfile=${configdir}/mysqluser.txt.encrypted
mysqlpassfile=${configdir}/mysqlpass.txt.encrypted
backuppassfile=${configdir}/backuppass.txt.encrypted

#Defines default database
if [[ -z $database ]];
then
	database="DB_Kunden"
fi

#decrypt credentials
openssl rsautl -decrypt -inkey $privkey -in $mysqluserfile -out ${configdir}/mysqluser.txt
openssl rsautl -decrypt -inkey $privkey -in $mysqlpassfile -out ${configdir}/mysqlpass.txt
openssl rsautl -decrypt -inkey $privkey -in $backuppassfile -out ${configdir}/backuppass.txt
password=`cat ${configdir}/backuppass.txt`
sqluser=`cat ${configdir}/mysqluser.txt`
sqlpass=`cat ${configdir}/mysqlpass.txt`


#creates directories if not already exist
mkdir -p $workingdir
mkdir -p $backupdir
cd $backupdir

#counts files in $backupdir
filenmbr=`ls | wc -l`

#If files >6 delete oldest
if [ $filenmbr -gt 6 ];
then
	oldestfile=`ls -rt | head -1`
    rm -rf $oldestfile
fi

#change to workingdir
cd $workingdir
#filename is database and date
_file=${database}.sql.${DATE}
#login to mysql and get $database. save to $_file
mysqldump -u root -p$sqlpass --databases $database > $_file
#make archiv of backup, and encrypt it. output is $_file.encrypted
tar cvzf - $_file | openssl des3 -salt -k $password | dd of=${_file}.encrypted
#$_file is know encrypted file
_file=${_file}.encrypted
#move backuped file to $workingdir
mv $_file ${backupdir}/${_file}
#Clean up $workingdir
rm -rf $workingdir
rm ${configdir}/mysqluser.txt
rm ${configdir}/mysqlpass.txt
rm ${configdir}/backuppass.txt