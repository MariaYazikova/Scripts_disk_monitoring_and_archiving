#!/bin/bash

#проверка количества введеных аргументов
if [ "$#" -ne 2 ]; then
    echo "Error: not two arguments."
	echo "Usage: $0 <directory_path> <threshold_percentage>"
	exit 1
fi

#создание переменных с папкой и порога в процентах
DIR="$1"
THRESHOLD="$2"
#проверка сущестования директории
if [ ! -d "$DIR" ]; then
	echo "Error: this directory path is not a folder or does not exist."
	exit 1
fi

#проверка порога на число от 0 до 100
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 0 ] || [ "$THRESHOLD" -gt 100 ]; then
    echo "Error: threshold percentage should be a number from 0 to 100."
    exit 1
fi

#получение размера папки и файловой системы, в которой она хранится
DIR_SIZE=$(du -sm "$DIR" | awk '{print $1}')
TOTAL_SIZE=$(df -m "$DIR" | awk 'NR==2 {print $2}')
#вычисление заполненности папки в процентах
USAGE=$(echo "scale=2; (100 *  $DIR_SIZE / $TOTAL_SIZE)" | bc)

#вывод информации о размере папки в кб и ее заполненности в процентах
echo "Size of '$DIR': $DIR_SIZE MB"
echo "Total size: $TOTAL_SIZE MB"
echo "Usage percentage of '$DIR': $USAGE%"

#проверка на превышение порога
if [[ $(echo "$USAGE > $THRESHOLD" | bc) -eq 1 ]]; then
    echo "The threshold has been exceeded. Сreating an archive..."
    #определение домашней директории пользователя
    HOME_DIR="$HOME"

    #имя архива с датой
    DATE=$(date +%Y-%m-%d_%H:%M:%S)
    ARCHIVE="archieve_$DATE.tar"
    echo "The archieve '$ARCHIVE' has been created."
    ARCHIVE_CREATED=true #флаг для отслеживания создания архива
else 
    echo "The threshold has not been exceeded. No archiving is created."
    ARCHIVE_CREATED=false
fi

#архивирование
while [[ $(echo "$USAGE > $THRESHOLD" | bc) -eq 1 ]]; do
    #инициализирует самый старый файл
    FILE=$(find "$DIR" -type f -printf '%T@ %p\n' | sort -n | awk '{print $2}' | head -n 1)

    #архивирование последнего файла 
    echo "Archiving file '$FILE'..."
    tar -rf "$HOME_DIR/$ARCHIVE" "$FILE" || {
        echo "Can't archieve file '$FILE' from '$DIR'"
        continue
    }

    #удаление файла из исходной папки в случае успешной архивации
    echo "Removing file '$FILE'..."
    rm -f "$FILE" || {
        echo "Can't remove file '$FILE' from '$DIR'"
        continue
    }

    #вывод об успешной архивации и удаления файла 
    echo "File archieved and removed from '$DIR'."

    #обновление переменных с размерами
    DIR_SIZE=$(du -sm "$DIR" | awk '{print $1}')
    TOTAL_SIZE=$(df -m "$DIR" | awk 'NR==2 {print $2}')
    USAGE=$(echo "scale=2; (100 *  $DIR_SIZE / $TOTAL_SIZE)" | bc)
    echo "Size of '$DIR': $DIR_SIZE MB"
    echo "Usage percentage of '$DIR': $USAGE%"

    #небольшая пауза в 1 секунду перед следующей итерацией
    sleep 1
done

#сжатие архива
if [ "$ARCHIVE_CREATED" = true ]; then
    echo "Compressing archieve '$ARCHIVE'..."
    gzip "$HOME_DIR/$ARCHIVE"
    echo "Archieve compressed to '$ARCHIVE.gz'."
    echo "File archiving from '$DIR' to '$HOME_DIR/$ARCHIVE' is complete."
fi
