#!/bin/bash

#проверка переданных аргументов
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <image_file_path> <mount_directory>"
    exit 1
fi

FILE="$1" #образ раздела
MOUNT="$2" #путь к директории для монтирования

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

#проверка установки fuse2fs
if ! dpkg -l | grep -q fuse2fs; then
    echo "fuse2fs isn't installed."
    echo "To install use command:"
    echo "sudo apt install fuse2fs"
    exit 1
fi

#удаление раздела
if mount | grep "$MOUNT" > /dev/null 2>&1; then
    if fusermount -u "$MOUNT"; then #размонтирвоание раздела
        if [ -f "$FILE" ]; then
            rm "$FILE" #удаление образа раздела
        fi
        if [ -d "$MOUNT" ]; then
            rmdir "$MOUNT" #удаление директории монтирования
        fi
    fi
    echo "Previous chapter deleted."
fi

#создание раздела
if [ ! -f "$FILE" ]; then
    dd if=/dev/zero of="$FILE" bs=1M count=2048 > /dev/null 2>&1 #создание образа раздела размером 2048МБ
    #форматирование раздела
    mkfs.ext4 "$FILE" > /dev/null 2>&1
    mkdir -p  "$MOUNT" #создание директории для монтирования
    if fuse2fs "$FILE" "$MOUNT" > /dev/null 2>&1; then #монтирование
        echo "New chapter created."
    else
        echo "New chapter not created."
        exit 1
    fi
fi
