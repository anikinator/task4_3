#!/bin/bash

# Simple Backup anikinator@gmail.com

#uncomment to check stdout > stderr redirect
#exec 2>> errors

#Make and check backup dir
BACKUPDIR='/tmp/backups'
if ! [ -d "$BACKUPDIR" ]; then

	mkdir -p "$BACKUPDIR" 
fi

# Check parameters
if [ $# -ne 2 ]; then

	E_ARGNUM="Error 1. Only two parameters are allowed, you've entered $#."
	echo $E_ARGNUM 1>&2
	exit 1
fi

## First Parameter - Directory to backup
if ! [ -d "$1" ]; then

	E_FIRSTPARAM= "Error 2. Directory $1 not existed. Nothing to backup." 
	echo $E_FIRSTPARAM 1>&2
	exit 2
fi

## Second Parameter - Backups count
if ! [[ $2 =~ ^[0-9]+$ && $2 != 0 ]]; then

	E_SECONDPARAM="Error 3. Second parameter must be a number and not zero."
	echo $E_SECONDPARAM 1>&2
	exit 3
fi

# Strip directory path, rotate and Backup

DIRTOBACKUP=${1#"/"}  
DIRTOBACKUP=${DIRTOBACKUP%"/"}  
DIRTOBACKUP=${DIRTOBACKUP//"/"/"-"}  

# Full path to backup and backup name
BACKUPNAME="$BACKUPDIR/$DIRTOBACKUP"

OLDBACKUPSCOUNT=`ls $BACKUPDIR | grep $DIRTOBACKUP."[0-9]".tar.gz | wc -l`
#OLDBACKUPSCOUNT=$(($OLDBACKUPSCOUNT-1))
NUMEREDBACKUPS=$(($2-1))

## If $2 backups count parameter changed and it less then backups in backup storage
if [ "$2" -lt "$OLDBACKUPSCOUNT" ];then

	for ((x=$OLDBACKUPSCOUNT;x>$NUMEREDBACKUPS;x--));do

		if [ -f "$BACKUPNAME.$x.tar.gz" ]; then
			rm -f "$BACKUPNAME.$x.tar.gz"
		fi
	done
fi


## Delete oldest backup $2-1
if [ -f "$BACKUPNAME.$NUMEREDBACKUPS.tar.gz" ]; then

	rm -f "$BACKUPNAME.$NUMEREDBACKUPS.tar.gz"
fi

## Rotate old backups
## Line 78, 79 - fixes rotation logic if accedenatly "middle" copy(ies) was deleted.
## It just creates empty file with right name, even script worked at first time.
for ((i=$NUMEREDBACKUPS;i>=1;i--))
 do
	if [ -f "$BACKUPNAME.$i.tar.gz" ]; then

		mv "$BACKUPNAME.$i.tar.gz" "$BACKUPNAME.$((i+1)).tar.gz"
#	else
#		touch "$BACKUPNAME.$i.tar.gz"
	fi
done

## Rename previous backup
if [ -f "$BACKUPNAME.tar.gz" ]; then

	mv "$BACKUPNAME.tar.gz" "$BACKUPNAME.1.tar.gz"
fi

## Fresh Backup
tar -zcf "${BACKUPNAME}.tar.gz" "$1" 1>&2

