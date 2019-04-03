#!/bin/bash
##
# Shared configuration settings
# Script created on 02-04-19
#
# echo raistlin1640 | sudo mkdir ${OFFSITE_DEST}${TIMESTAMP}
# USE A GOOD LONG PASSPHRASE! DO NOT LOSE IT!
export PASSPHRASE="d0v13&nd1s3t0v1&s&g&1n."
#
# 3 is a good verbosity level for daily runs, but you may want to start with
# 5 or above if you are just setting up
VERBOSITY=3
# If duplicity finds this file in any folder, that folder won't be backed up.
# You can specify separate LOCAL and OFFSITE settings below, but mind that you
# will need to touch both files in folders that you want to exclude from both.
#EXCLUDE_IF_PRESENT=".nobak"
EXCLUDE_IF_PRESENT=".nocopiar"
# Read the manpage for the exclude filelist format. You can specify
# different local and remote filelists in the sections below if you like.
DIR="/home/aberral/"
EXCLUDE_FILELIST="/home/aberral/.duplicity/excludes"
##
# OFFSITE backup configuration settings
#
# Set this to point to your Google Drive location
OFFSITE_DEST="gdocs://aberralgonzalez@usal.es/trinitybu/"
# You can specify a different offsite-specific exclude filelist here
OFFSITE_EXCLUDE_FILELIST=$EXCLUDE_FILELIST
# You can specify an offsite-specific exclude-if-present filename here
# OFFSITE_EXCLUDE_IF_PRESENT=$EXCLUDE_IF_PRESENT
# You don't want to make full off-site backups too frequently, as this
# would require re-uploading full contents all over again. 90 days is a
# good metric
OFFSITE_FULL_EVERY="90D" 
# You probably don't want to keep more than 1 full remote backup
OFFSITE_KEEP_FULL=3
# You should print out the contents of this file, in case you
# need to restore from off-site backups after a major disaster.
export GOOGLE_DRIVE_SETTINGS="/home/aberral/.duplicity/credentials"
##
# LOCAL backup configuration settings
#
# Set this to point to your removable storage
# or comment out if you don't want local backups
LOCAL_DEST="/mnt/verbatimHD/trinitybu/"
# You can specify a different local-specific exclude filelist here
LOCAL_EXCLUDE_FILELIST=$EXCLUDE_FILELIST
# You can specify a local-specific exclude-if-present filename here
LOCAL_EXCLUDE_IF_PRESENT=$EXCLUDE_IF_PRESENT
# Create full backups every 30 days
LOCAL_FULL_EVERY="30D"
# Since you probably have lots of local room, keep 3 full backups
LOCAL_KEEP_FULL=3
##
# Perform an off-site backup
#
# We create both directories

if [ ! -z "${OFFSITE_DEST}" ]; then
    # Clean up any previously failed runs
    GOOGLE_DRIVE_SETTINGS=$GOOGLE_DRIVE_SETTINGS duplicity --verbosity=0 cleanup --force ${OFFSITE_DEST}
    echo
    if [ $VERBOSITY -gt 0 ]; then
        echo "Performing an offsite backup to ${OFFSITE_DEST}"
	echo
    fi
    GOOGLE_DRIVE_SETTINGS=$GOOGLE_DRIVE_SETTINGS duplicity \
	    --verbosity=$VERBOSITY \
	    --allow-source-mismatch \
	    --full-if-older-than=$OFFSITE_FULL_EVERY \
	    --exclude-if-present=$OFFSITE_EXCLUDE_IF_PRESENT \
	    --exclude-filelist=$OFFSITE_EXCLUDE_FILELIST \
	    $DIR ${OFFSITE_DEST}
    echo
    if [ $VERBOSITY -gt 0 ]; then
        echo "Removing all but ${OFFSITE_KEEP_FULL} full backup from ${OFFSITE_DEST}"
	echo
    fi
    GOOGLE_DRIVE_SETTINGS=$GOOGLE_DRIVE_SETTINGS duplicity --verbosity=$VERBOSITY \
	remove-all-but-n-full ${OFFSITE_KEEP_FULL} \
	--force ${OFFSITE_DEST}
    echo 
fi
##
# Perform a local backup

if [ ! -z "${LOCAL_DEST}" ]; then
    # If the dir does not exist, we'll assume that you forgot to mount the
    # external disk.
    if [ -d "${LOCAL_DEST}" ]; then
        # Clean up any previously failed runs
        duplicity --verbosity=0 cleanup --force "file://${LOCAL_DEST}"
        echo
        if [ $VERBOSITY -gt 0 ]; then
            echo "Performing a local backup to ${LOCAL_DEST}"
            echo
        fi
        # echo raistlin1640 | sudo mkdir ${LOCAL_DEST}${TIMESTAMP}
        duplicity \
		--verbosity=$VERBOSITY \
		--allow-source-mismatch \
		--full-if-older-than=$LOCAL_FULL_EVERY \
		--exclude-if-present=$LOCAL_EXCLUDE_IF_PRESENT \
		--exclude-filelist=$LOCAL_EXCLUDE_FILELIST \
		$DIR "file://${LOCAL_DEST}"
        echo
        if [ $VERBOSITY -gt 0 ]; then
            echo "Removing all but ${LOCAL_KEEP_FULL} full backup from ${LOCAL_DEST}"
	    echo
        fi
        duplicity --verbosity=$VERBOSITY \
		remove-all-but-n-full ${LOCAL_KEEP_FULL} \
		--force "file://${LOCAL_DEST}" 
        echo
    else
        echo "${LOCAL_DEST} not found. Did you forget to mount it?"
        echo
    fi
fi
