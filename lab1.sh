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
find "$DIR" -type f -printf '%TY-%Tm-%Td_%TH:%TM:%TS %p\n' | sort -t ' ' -k 1,1 -r
#определение домашней директории пользователя
HOME_DIR="$HOME"

#имя архива с датой
DATE=$(date +%Y-%m-%d_%H:%M:%S)
ARCHIVE="archieve_$DATE.tar.gz"
#проверка на превышение порога и архивирование
while [[ $USAGE -ge $THRESHOLD ]]; do
    #инициализирует самый старый файл
    FILE=$(find "$DIR" -type f)

    #архивирование последнего файла 
    echo "Archiving file '$FILE' to '$HOME_DIR/$ARCHIVE'..."

    tar -rvzf "$HOME_DIR/$ARCHIVE" "$FILE" || {
        echo "Can't archieve files from '$DIR'"
        continue
    }

    #удаление файла из исходной папки в случае успешной архивации
    echo "Removing file '$FILE'..."
    rm -f "$FILE" || {
        echo "Can't remove files from '$DIR'"
        continue
    }

    echo "File archieved and removed from '$DIR'"
    #вывод информации о размере папки в кб и ее заполненности в процентах
    DIR_SIZE=$(du -sk "$DIR" | awk '{print $1}')
    TOTAL_SIZE=$(df -k "$DIR" | awk 'NR==2 {print $2}')
    #вычисление заполненности папки в процентах
    USAGE=$(echo "scale=2; (100 *  $DIR_SIZE / $TOTAL_SIZE)" | bc)
    echo "Size of '$DIR': $DIR_SIZE KB"
    echo "Usage percentage of '$DIR': $USAGE%"
    #небольшая пауза в 1 секунду перед следующей итерацией
    sleep 1
done
