#!/bin/bash
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <directory_path>"
	exit 1
fi

DIR="$1"

if [ ! -d "$DIR" ]; then
	echo "Error: this directory path is not a folder or does not exist"
	exit 1
fi

USAGE=$(df "$DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
echo "Usage of '$DIR': $USAGE%"

if [[ $USAGE -ge 70 ]]; then
    tar -cvzf /backup/small.tar.gz /log*
    rm -f /log*
fi
