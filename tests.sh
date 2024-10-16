#!/bin/bash

BASE_SCRIPT='./lab1.sh' #путь к основному скрипту
TEST="./test_dir" #путь к тестовой папке
mkdir -p "$TEST" #создание тестовой папки

#функция очистки тестовой папки и размонтирование раздела
remove() {
    rm -rf "$TEST"
    echo "All files removed from '$TEST'."
}

#функция проверки создания архива
check_creation_of_archive() {
    ARCHIVE=$(find $HOME -name "archieve_*.tar.gz" -newermt "$START_TIME" 2>/dev/null)
    if [ -f "$ARCHIVE" ]; then
        echo "Test passed: Archive created."
    else
        echo "Test failed: Archive not created."
    fi
}

#функция проверки не создания архива
check_no_creation_of_archive() {
    ARCHIVE=$(find $HOME -name "archieve_*.tar.gz" -newermt "$START_TIME" 2>/dev/null)
    if [ -z "$ARCHIVE" ]; then
        echo "Test passed: Archive not created."
    else
        echo "Test failed: Archive created."
    fi
}

#создание текстовых файлов на 800мб внутри тестовой папки
creating_files() {
    SIZE=$(du -sm "$TEST" | awk '{print $1}')
    SIZE=${SIZE:-0}

    if [ "$SIZE" -lt 500 ]; then
        echo "Creating test files..."
        for i in {1..8}; do
            FILE="$TEST/file$(date +%s%N).txt"
            fallocate -l 100M "$FILE"
        done
    fi
}

#Тест №1: превышение порога (архивирование n файлов)
test_threshold_exceeded() {
    echo "Running the TEST №1..."
    START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    creating_files
    "$BASE_SCRIPT" "$TEST" 30

    check_creation_of_archive
}

#Тест №2: порог 0% (архивируются все файлы)
test_full_threshold_exceeded() {
    echo "Running the TEST №2..." 
    START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    creating_files
    "$BASE_SCRIPT" "$TEST" 0


    check_creation_of_archive
}

#Tecт №3: порог 100% (ничего не архивируется)
test_no_threshold_exceeded() {
    echo "Running the TEST №3..."
    START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    creating_files
    "$BASE_SCRIPT" "$TEST" 100

    check_no_creation_of_archive
}

#Тест №4: директория не существует (преждевременное завершение скрипта)
test_invalid_directory() {
    echo "Running the TEST №4..."
    creating_files

    OUTPUT=$("$BASE_SCRIPT" "./invalid_dir" 70 2>&1)
    if [[ "$OUTPUT" == *"Error: this directory path is not a folder or does not exist."* ]]; then
        echo "Test passed: Invalid directory error was correctly handled."
    else
        echo "Test failed: Invalid directory error wasn't handled correctly."
    fi
}

#Тест №5: порог больше 100 (преждевременное завершение скрипта)
test_invaid_threshold1() {
    echo "Running the TEST №5..."
    creating_files

    OUTPUT=$("$BASE_SCRIPT" "$TEST" 101 2>&1)
    if [[ "$OUTPUT" == *"Error: threshold percentage should be a number from 0 to 100."* ]]; then
        echo "Test passed: Invalid threshold > 100 was correctly handled."
    else
        echo "Test failed: Invalid threshold > 100 wasn't handled correctly."
    fi

}

#Тест №6: порог меньше 0 (преждевременное завершение скрипта)
test_invaid_threshold2() {
    echo "Running the TEST №6..."
    creating_files

    OUTPUT=$("$BASE_SCRIPT" "$TEST" -1 2>&1)
    if [[ "$OUTPUT" == *"Error: threshold percentage should be a number from 0 to 100."* ]]; then
        echo "Test passed: Invalid threshold < 0 was correctly handled."
    else
        echo "Test failed: Invalid threshold < 0 wasn't handled correctly."
    fi
}

#Teст №7: недостаток аргументов (преждевременное завершение скрипта)
test_invalid_count_of_args1() {
    echo "Running the TEST №7..."
    creating_files
    
    OUTPUT=$("$BASE_SCRIPT" "$TEST" 2>&1)
    if [[ "$OUTPUT" == *"Error: not two arguments."* ]]; then
        echo "Test passed: Error for insufficient arguments was correctly handled."
    else
        echo "Test failed: Error for insufficient arguments wasn't handled correctly."
    fi

}

#Teст №8: превышение аргументов (преждевременное завершение скрипта)
test_invalid_count_of_args2() {
    echo "Running the TEST №8..."
    creating_files
    
    OUTPUT=$("$BASE_SCRIPT" "$TEST" 22 "arg" 2>&1)
    if [[ "$OUTPUT" == *"Error: not two arguments."* ]]; then
        echo "Test passed: Error for too many arguments was correctly handled."
    else
        echo "Test failed: Error for too many arguments wasn't handled correctly."
    fi
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