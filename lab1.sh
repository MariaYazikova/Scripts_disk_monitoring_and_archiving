#!/bin/bash

#проверка введеных аргументов
if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <directory_path> <threshold_percentage>"
	exit 1
fi

#создание переменных с папкой и порога в процентах
DIR="$1"
THRESHOLD="$2"

#проверка сущестования директории
if [ ! -d "$DIR" ]; then
	echo "Error: this directory path is not a folder or does not exist"
	exit 1
fi

#проверка порога на число от 0 до 100
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 0 ] || [ "$THRESHOLD" -gt 100 ]; then
    echo "Error: threshold percentage should be a number from 0 to 100"
    exit 1
fi

#получение размера папки и файловой системы, в которой она хранится
DIR_SIZE=$(du -sk "$DIR" | awk '{print $1}')
TOTAL_SIZE=$(df -k "$DIR" | awk 'NR==2 {print $2}')
#вычисление заполненности папки в процентах
USAGE=$(echo "scale=2; (100 *  $DIR_SIZE / $TOTAL_SIZE)" | bc)

#вывод информации о размере папки в кб и ее заполненности в процентах
echo "Size of '$DIR': $DIR_SIZE KB"
echo "Usage percentage of '$DIR': $USAGE%"

#проверка на превышение порога и архивирование
if [[ $(echo "$USAGE >= $THRESHOLD" | bc) -eq 1 ]]; then
    #проверка существования директории /backup и ее создание в противном случае
    BACKUP="/backup"
    if [ ! -d "$BACKUP" ]; then
        echo "Directory '$BACKUP' doesn't exist. Creating..."
        mkdir "$BACKUP" || {
            echo "Can't create $BACKUP"
            exit 1
        }
    fi

    #архивирование файлов
    echo "Archiving files from '$DIR' to '$BACKUP/small.tar.gz'..."
    tar -cvzf "$BACKUP/small.tar.gz" -C "$DIR" . || {
        echo "Can't archieve files from '$DIR'"
        exit 1
    }

    #удаление файлов из исходной папки в случае успешной архивации
    echo "Removing files from '$DIR'..."
    rm -rf "$DIR/"* || {
        echo "Can't remove files from '$DIR'"
        exit 1
    }
    echo "Files archieved and removed from '$DIR'"
fi
