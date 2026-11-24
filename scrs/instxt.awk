# Вставка текста в строку
# Использование: awk-f instxt.awk line_num pos text file.txt [outfile]
# Вставляет text ВНУТРЬ строки line_num на позицию pos (символы сдвигаются). Если pos больше длины строки — вставка в конец строки
# line_num — номер строки (от 1). Если line_num больше числа строк — добавляется новая строка в конец файла
# pos — позиция вставки (от 1). Если pos больше длины строки — вставка в конец строки
# text — текст для вставки (если содержит пробелы, заключайте в кавычки)
# outfile — необязательный, имя файла для записи результата, если не указан — запись в исходный файл

BEGIN {
    if (length(ARGV) < 5) {
        print "Ошибка: требуется 4 аргумента: line_num pos text file.txt" > "/dev/stderr"
        exit 1
    }
    
    line_num = ARGV[1] + 0
    pos = ARGV[2] + 0
    text = ARGV[3]
    
    if (line_num < 1) {
        print "Ошибка: line_num должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    if (pos < 1) {
        print "Ошибка: pos должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
    delete ARGV[2]
    delete ARGV[3]
    
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
    
    line_found = 0
}

function out(s) {
    print s > outfile
}

NR == line_num {
    line_found = 1
    line_len = length($0)
    if (pos > line_len) {
        # Вставка в конец строки
        out($0 text)
    } else {
        out(substr($0, 1, pos - 1) text substr($0, pos))
    }
    next
}

{
    out($0)
}

END {
    # Если номер строки был больше числа строк — добавляем новую строку в конец
    if (line_found == 0) {
        out(text)
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