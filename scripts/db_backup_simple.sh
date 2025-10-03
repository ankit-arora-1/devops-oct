#!/bin/bash
#
#DB Backup script:
#Aim: Write a script that backs up a db
#Check if backup dir exists or not. If not, create it.
#Check if backup dir has enough space or not
#Check if database exists or not. if not, exit the script.
#if it exists:
#Simulate backup (copy some random text to backup file)
#Check if the backup file exists or not
#Check if the size if large or small and print it
#

database_name="production_db"
backup_date=$(date +%Y%m%d)
backup_dir="/home/ubuntu/backup/data_$backup_date"
backup_file="$backup_dir/${database_name}_backup.txt"

# check if backup dir exists or not
if [ -d "$backup_dir" ]; then
        echo "Backup dir already exists"
else
        echo "Backup dir does not exist. Creating..."
        mkdir -p "$backup_dir"
fi

# check if enough space is available
available_space=$(df ./backup | awk 'NR == 2 {print $4}')
minimum_space=100

if [ $available_space -gt $minimum_space ]; then
        echo "Enough disk space is available"
else
        echo "Error: Not enough disk space. Exiting..."
        exit 1
fi


if [ -f "./$database_name" ]; then
        echo "Database found, starting backup..."
                echo "Database found, starting backup..."

        #Backup
        echo "Backing up in progress"
        echo "Database backup abc" > $backup_file

        if [ -f "$backup_file" ]; then
                echo "Backup successfully created"

                #check the size. If big, compress it
                file_size=$(ls -l "$backup_file" | awk '{print $5}')
                large_size=500
                if [ "$file_size" -ge "$large_size" ]; then
                        echo "File is large. Compressing..."
                else
                        echo "File is small. Keeping it as it is"
                fi
        else
                echo "Backup failed"
                exit 1
        fi

else
        echo "Database not found. Exiting..."
        exit 1
fi

echo "Backup completed"
