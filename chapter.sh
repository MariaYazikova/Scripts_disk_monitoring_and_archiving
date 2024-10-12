
#!/bin/bash

BASE_SCRIPT='./lab1.sh' 
NUMBER=$1 #принимает номер раздела
FS_TYPE="ext4" #тип файловой системы
MOUNT="/mnt/data" #точка монтирования
#создание раздела
sudo fdisk "$DIR" << EOF
n
p
$NUMBER
2048
+2048
w
EOF
#форматирование раздела
sudo mkfs.ext4 $DIR > /dev/null 2>&1
#создание точки монтирования
sudo mkdir -p "$MOUNT"
#монтирование раздела
sudo mount "$DIR"$NUMBER "$MOUNT"
#добавление записи в fstab
echo "$DIR" "$MOUNT"$NUMBER" "$FS_TYPE" defaults 0 2" | sudo tee -a /etc/fstab 
#проверка монтирования
df -h | grep "$MOUNT"
echo "Раздел успешно создан и смонтирован!"
