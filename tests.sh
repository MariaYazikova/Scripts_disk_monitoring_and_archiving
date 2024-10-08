#!/bin/bash

BASE_SCRIPT='./lab1.sh' #путь к основному скрипту
TEST="./test_dir" #путь к тестовой папке
mkdir -p "$TEST" #создание тестовой папки

#функция очистки тестовой папки
remove() {
    rm -rf "$TEST"
}

#создание текстовых файлов на 800мб внутри тестовой папки
creating_files() {
    SIZE=$(du -sm "$TEST" | awk '{print $1}')
    SIZE=${SIZE:-0}
    if [ "$SIZE" -lt 500 ]; then
        echo "Creating test files..."
        for i in {1..10}; do
            fallocate -l 100M "$TEST/file№$i.txt"
        done
    fi
}

#Тест №1: превышение порога (архивирование n файлов)
test_threshold_exceeded() {
    echo "Running the TEST №1..."
    creating_files
    "$BASE_SCRIPT" "$TEST" 50
}

#Тест №2: порог 0% (архивируются все файлы)
test_full_threshold_exceeded() {
    echo "Running the TEST №2..." 
    creating_files
    "$BASE_SCRIPT" "$TEST" 0
}

#Tecт №3: порог 100% (ничего не архивируется)
test_no_threshold_exceeded() {
    echo "Running the TEST №3..."
    creating_files
    "$BASE_SCRIPT" "$TEST" 100
}

#Тест №4: директория не существует (преждевременное завершение скрипта)
test_invalid_directory() {
    echo "Running the TEST №4..."
    creating_files
    "$BASE_SCRIPT" "./invalid_dir" 70
}

#Тест №5: порог больше 100 (преждевременное завершение скрипта)
test_invaid_threshold1() {
    echo "Running the TEST №5..."
    creating_files
    "$BASE_SCRIPT" "$TEST" 101
}

#Тест №6: порог меньше 0 (преждевременное завершение скрипта)
test_invaid_threshold2() {
    echo "Running the TEST №6..."
    creating_files
    "$BASE_SCRIPT" "$TEST" -1
}

#Teст №7: недостаток аргументов (преждевременное завершение скрипта)
test_invalid_count_of_args1() {
    echo "Running the TEST №7..."
    creating_files
    "$BASE_SCRIPT" "$TEST"
}

#Teст №8: превышение аргументов (преждевременное завершение скрипта)
test_invalid_count_of_args2() {
    echo "Running the TEST №8..."
    creating_files
    "$BASE_SCRIPT" "$TEST" 22 "arg"
}


#вызов тестов
test_threshold_exceeded
echo ""
test_full_threshold_exceeded
echo ""
test_no_threshold_exceeded
echo ""
test_invalid_directory
echo ""
test_invaid_threshold1
echo ""
test_invaid_threshold2
echo ""
test_invalid_count_of_args1
echo ""
test_invalid_count_of_args2
echo ""

#завершение и очищение
echo "All tests completed"
remove