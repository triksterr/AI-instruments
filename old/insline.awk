# Вставка строки файл
# Использование: awk-f insline.awk line_num text file.txt [outfile]
# Вставляет text как новую строку ПЕРЕД строкой с номером line_num
# line_num — номер строки (от 1). Если line_num больше числа строк в файле — вставка в конец файла
# text — текст для вставки (если содержит пробелы, заключайте в кавычки)
# outfile — необязательный, имя файла для записи результата, если не указан — запись в исходный файл

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется 3 аргумента: line_num text file.txt" > "/dev/stderr"
        exit 1
    }
    
    line_num = ARGV[1] + 0
    text = ARGV[2]
    
    if (line_num < 1) {
        print "Ошибка: line_num должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
    delete ARGV[2]
    
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
    
    inserted = 0
}

function out(s) {
    print s > outfile
}

NR == line_num {
    out(text)
    inserted = 1
}

{
    out($0)
}

END {
    # Если номер строки был больше числа строк — добавляем в конец
    if (inserted == 0) {
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