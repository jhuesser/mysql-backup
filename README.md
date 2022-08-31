# mysql-backup
This was a schoolproject. It should have 3 skripts, one for restarting the demon, one for creating a backup and one for restoring the backup. It was ratet with the best mark.

#Installation
download all files. Give execution rights to installer.sh and run it with root privilleges.

restart mysql:
```
remysql
```
create backup

```
sqlbak [database]
```
Recover backup

```
mysql-recovery [database]
```


#criteria
The criteria from school was the following:

##Task 1: installation
- install mysql-server on a debian like VM.
- Secure the mysql-installation
- change the root password at least once
- create database "Clients"
- import a given file to the database
- write a script which restarts the mysql-demon

##Task 2: Backup
- Take a backup from the Clients DB with mysqldump
- The backup must be taken at midnight every day
- The backup must be packeged with tar and encrypted with the password "F45e$q%fh}"
- The backup must be stored at /backup
- The date must be the sufflix of the backup-file
- 7 files must be stored max.
- If ein 8th file will be created, the oldest one must be deleted
- All this steps must be done with a bash script
- create a cron job for the bashscript

##Task 3: Restore
- Delete the example table. Test the restore: decrypt, depackage and import the backup manually.
- Create a bash script, which automates the above proccess.

#Notes
The import file is aviable at www.domayntec.ch/addressen.sql

