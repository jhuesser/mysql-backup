#!/bin/bash


#Script starts at bottom.

function instellation {
	#Starts full instellation	
	#make scripts executable
	chmod +x sqlbak.sh
	chmod +x restart.sh
	chmod +x recovery.sh
	#copy to /bin for easy call
	mv sqlbak.sh /usr/bin/sqlbak
	mv restart.sh /usr/bin/remysql
	mv recovery.sh /usr/bin/mysql-recovery
	#make config directories for config & key pairs
	mkdir -p $configdir
	mkdir -p $keydir
	mkdir -p $privkeydir
	mkdir -p $pubkeydir
	
	
}

function encryptCredentials {
	#Encrypts mysql-User credentials
	#File to encrypt
	file=$1
	#encrypt file with public key
	openssl rsautl -encrypt -inkey $pubkey -pubin -in $file -out ${file}.encrypted	
	
}
	
function generateKey {
	#Generates keypair
	#Ask if key pair exist.
	read -p "Do you need a keypair (only on first installation)? [Y/n] " needkey
	if [[ -z "$needkey" ]] || [[ $needkey == "Y" ]] || [[ $needkey == "y" ]]; then
		#Generate private key
		openssl genpkey -algorithm RSA -out ${privkeydir}/private_key.pem -pkeyopt rsa_keygen_bits:2048
		
		#Generate public key
		openssl rsa -pubout -in ${privkeydir}/private_key.pem -out ${pubkeydir}/public_key.pem	
	
	elif [[ $needkey == "n" ]] || [[ $needkey == "N" ]]; then
		#Do nothing
		echo "No keys generated"
		return
	
	else
		#Ask again
		generateKey
		return
	fi
	
	
	
	
}
	
function credentials {
	#Save mysql credentials
	#Generates keys
	generateKey
	#set key values
	privkey=${privkeydir}/private_key.pem
	pubkey=${pubkeydir}/public_key.pem
	#ask for credentials and saves to value
	read -p "Enter a valid mySQL-Username: " sqluser
	read -s -p "Enter the mySQL Passwortfor user $sqluser: " sqlpass
	echo ''
	#save credentials to file
	echo $sqluser > ${configdir}/$userfile
	echo $sqlpass > ${configdir}/$passfile
	#encrypt credentials
	encryptCredentials ${configdir}/$userfile
	encryptCredentials ${configdir}/$passfile
	rm ${configdir}/$userfile
	rm ${configdir}/$passfile
	
		
}


function registerCronjob {
	#make file
	touch mycron
	#write cronjob to file
	echo "00 00 * * * /usr/bin/sqlbak" > mycron
	#register cronjob
	crontab mycron
	#remove file
	rm -f mycron
}

function _start {
	#starts here
	#full instellation or just new mysql-credentials'
	read -p "Do you want a complete instellation or just update the credentials? [C/u] " choice
	if [[ -z "$choice" ]] || [[ $choice == "c" ]] || [[ $choice == "C" ]]; then
		#perform full isntellation
		instellation
		credentials
		registerCronjob
	
	elif [[ $choice == "u" ]] || [[ $choice == "U" ]]; then
		#change credentials
		credentials
	
	else
		#start again
		_start
		return
	fi
	
}
#SCRIPT STARTS HERE

#working values
#configdir with credentials and keys stored
configdir=/etc/mysql-bzu
#file with username
userfile=mysqluser.txt
#file with password
passfile=mysqlpass.txt
#dir with keypair
keydir=${configdir}/keys
#dir with the privatekey
privkeydir=${keydir}/.private
#dir with the publickey
pubkeydir=${keydir}/public
#Starts the actual script
_start







