#!/bin/bash

#Working Values
database=$1
workingdir=/tmp/sqlbak
configdir=/etc/mysql-backup
backupdir=/backup
keydir=${configdir}/keys
privkey=${keydir}/.private/private_key.pem
mysqluserfile=${configdir}/mysqluser.txt.encrypted
mysqlpassfile=${configdir}/mysqlpass.txt.encrypted
backuppassfile=${configdir}/backuppass.txt.encrypted

#Use default DB name if empty
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

#Create and change directory
mkdir -p $workingdir
cd $backupdir

#search latest backup
latest=`ls -t | head -1`

#copy encrypted backup to workingdir
cp $latest ${workingdir}/$latest
cd $workingdir

#decrypt and unpack the backup
dd if=$latest | openssl des3 -d -k $password | tar xvzf -

#remove encrypted backup copy
rm -f $latest

#select latest file (=decrypted backup)
decryptedFile=`ls -t | head -1`

#create commands file and fill in with commands
touch commands.sql
echo "CREATE DATABASE IF NOT EXISTS ${database};" >> commands.sql 
echo "USE ${database};" >> commands.sql
echo "SOURCE ${workingdir}/${decryptedFile}" >> commands.sql

#execute the commands
mysql -u $sqluser -p$sqlpass < commands.sql 
#clean up working directory
rm -rf $workingdir
rm ${configdir}/mysqluser.txt
rm ${configdir}/mysqlpass.txt
rm ${configdir}/backuppass.txt