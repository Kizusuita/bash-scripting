#!/bin/bash

#### ---- error handling ---- ####

if [ "$#" -ne 2 ]; then
    echo "Usage: ./bkup <source_directory> <destination_directory>"
    exit 1
fi

source="$1"
dest="$2"

if [[ ! -d $source || ! -d $dest ]]; then
    echo "Source and destination should be directories."
    exit 1
fi

#### ------- make logs ------ ####

log="/tmp/log/backup.log" #Have to make this directory before running script

if [[ ! -d $log ]]; then
    mkdir /tmp/log
    touch /tmp/log/backup.log
fi

bkup_dir="$dest/$(date +"%F_%T")"

mkdir -p "$bkup_dir"

log () {
    local txt="$1"

    echo "$(date +"%F_%T") $txt" >> "$log"
}

#### --------- MAIN --------- ####

latest="$dest/latest"
timestamp=$(date +'%F_%T')
new_bkup="$dest/$timestamp"


# Backup Portion
if [[ ! -L "$latest" ]]; then
    echo "Performing inital backup..."
    mkdir -p "$new_bkup"
    rsync -a "$src/" "$latest"
else
    echo "Performing increamental backup..."
    mkdir -p "$new_bkup"
    rsync --a --delete --link-dest="$latest" "$src/" "$new_bkup/" #The delete is so that if a file in source is deleted, it'll also be deleted in dest so the most current backup is in line with the machine

    rm "$latest"
    ln -s "$new_bkup" "$latest"
fi

echo "Backup complete."

#### --- Backup Rotation ---- ####

bkup_count=$(ls -l "$dest" | wc -l)

if [[ $bkup > 10 ]]; then
    log "Backups have hit hard limit... backup rotation occurring... "
    old=$(ls -lt "$dest" | tail -n 1)
    rm -rf "$dest/$old"
    log "Oldest backup '$old' deleted."
fi

log "Backup completed from '$source' to '$bkup_dir'"
