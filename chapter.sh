#!/bin/bash
BASE_SCRIPT="./lab1.sh"
FILE="data.img"
MOUNT="/mnt/data" #точка монтирования
#проверка установки fuse
if ! dpkg -l | grep -q fuse; then
        echo "FUSE isn't installed."
        echo "To install use commands: "
        echo "sudo apt update"
        echo "sudo apt upgrade"
        echo "sudo apt install fuse3"
        echo "sudo apt-get install sshfs"
        exit 1
fi
#удаление раздела
if mount | grep "$MOUNT" > /dev/null; then
        sudo umount "$MOUNT"
        if [ -f "$FILE" ]; then
                sudo rm "$FILE"
        fi
fi
#создание раздела
if [! -f "$FILE"]; then
        sudo dd if=/dev/zero of="$FILE" bs=1M count=2048 #размер файла
        #форматирование раздела
        mkfs.ext4 "$FILE" > /dev/null 2>&1
        mkdir -p  "$MOUNT"
        fuse2fs "$FILE" "$MOUNT" > /dev/null 2>&1
fi
