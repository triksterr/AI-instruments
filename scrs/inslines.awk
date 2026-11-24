# Вставка многострочного блока в файл
# Использование: awk-f inslines.awk line_num block.txt file.txt [outfile]
# Вставляет содержимое block.txt как новые строки ПЕРЕД строкой с номером line_num
# line_num — номер строки (от 1). Если line_num больше числа строк в файле — вставка в конец файла
# block.txt — файл с многострочным блоком для вставки (пустой файл ничего не вставит)
# file.txt — исходный файл
# outfile — необязательный, имя файла для записи результата, если не указан — запись в исходный файл

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется 3 аргумента: line_num block.txt file.txt" > "/dev/stderr"
        exit 1
    }
    
    line_num = ARGV[1] + 0
    block_file = ARGV[2]
    
    if (line_num < 1) {
        print "Ошибка: line_num должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
    delete ARGV[2]
    
    # Читаем block.txt в массив
    block_count = 0
    while ((getline line < block_file) > 0) {
        sub(/\r$/, "", line)  # Удаляем \r для корректной работы с CRLF
        block_count++
        block_lines[block_count] = line
    }
    close(block_file)
    
    # Сохраняем имя входного файла
    input_file = ARGV[1]
    
    # outfile, если есть
    if (length(ARGV) >= 3) {
        outfile = ARGV[2]
        delete ARGV[2]
        in_place = 0
    } else {
        in_place = 1
        temp_dir = ENVIRON["TEMP"]
        if (temp_dir == "") temp_dir = ENVIRON["TMP"]
        if (temp_dir == "") {
            print "Ошибка: не найдена переменная окружения TEMP/TMP" > "/dev/stderr"
            exit 1
        }
        outfile = temp_dir "\\awk_temp_" PROCINFO["pid"] ".tmp"
    }
    
    # Создаём пустой временный файл (на случай, если исходный файл пустой)
    printf "" > outfile
    
    inserted = 0
}

function out(s) {
    print s > outfile
}

function out_block() {
    for (i = 1; i <= block_count; i++) {
        out(block_lines[i])
    }
}

NR == line_num {
    out_block()
    inserted = 1
}

{
    out($0)
}

END {
    # Если номер строки был больше числа строк — добавляем в конец
    if (inserted == 0) {
        out_block()
    }
    
    if (in_place) {
        close(outfile)
        cmd = "move /Y \"" outfile "\" \"" input_file "\" >nul 2>&1"
        result = system(cmd)
        if (result != 0) {
            print "Ошибка: не удалось заменить исходный файл" > "/dev/stderr"
            exit 1
        }
    }
}