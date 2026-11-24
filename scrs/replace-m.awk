# Поиск и замена многострочных блоков в файле.
# old и new — многострочные блоки текста, читаемые из файлов.
#
# Использование без диапазона: awk-f replace-m.awk old.txt new.txt file.txt [outfile.txt]
# Использование с диапазоном: awk-f replace-m.awk old.txt new.txt start [end] file.txt [outfile.txt]
# 
# old.txt — файл с искомым блоком
# new.txt — файл с новым блоком (пустой файл = удаление блока)
# start — начальная строка диапазона (от 1). Замена происходит, если ПЕРВАЯ строка блока находится в пределах [start, end].
# end — конечная строка диапазона (если не задана, проверяется только строка start)
# file.txt — исходный файл
# outfile.txt — имя файла для записи результата (если отсутствует — запись в исходный файл)

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется минимум 3 аргумента: old.txt new.txt file.txt" > "/dev/stderr"
        exit 1
    }
    
    old_file = ARGV[1]
    new_file = ARGV[2]
    
    delete ARGV[1]
    delete ARGV[2]
    
    # Читаем old.txt в массив
    old_count = 0
    while ((getline line < old_file) > 0) {
        sub(/\r$/, "", line)  # Удаляем \r для корректной работы с CRLF
        old_count++
        old_lines[old_count] = line
    }
    close(old_file)
    
    if (old_count == 0) {
        print "Ошибка: old.txt пуст или не существует" > "/dev/stderr"
        exit 1
    }
    
    # Читаем new.txt в массив
    new_count = 0
    while ((getline line < new_file) > 0) {
        sub(/\r$/, "", line)
        new_count++
        new_lines[new_count] = line
    }
    close(new_file)
    
    # Определяем параметры диапазона и outfile (аналогично replace.awk)
    if (ARGV[1] ~ /^[0-9]+$/) {
        start = ARGV[1] + 0
        delete ARGV[1]
        
        if (start < 1) {
            print "Ошибка: start должен быть >= 1" > "/dev/stderr"
            exit 1
        }
        
        if (ARGV[2] ~ /^[0-9]+$/) {
            end = ARGV[2] + 0
            delete ARGV[2]
        } else {
            end = start
        }
        
        input_file = ARGV[1]
        
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
    } else {
        start = 1
        end = 2147483647
        
        input_file = ARGV[1]
        
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
    }
    
    printf "" > outfile
}

{
    line = $0
    sub(/\r$/, "", line)
    file_count = NR
    file_lines[NR] = line
}

END {
    i = 1
    while (i <= file_count) {
        # Проверяем, начинается ли потенциальный блок в допустимом диапазоне
        if (i >= start && i <= end) {
            # Пытаемся сопоставить old_lines начиная с позиции i
            match_found = 1
            for (j = 1; j <= old_count; j++) {
                if (i + j - 1 > file_count) {
                    match_found = 0
                    break
                }
                if (file_lines[i + j - 1] != old_lines[j]) {
                    match_found = 0
                    break
                }
            }
            
            if (match_found) {
                # Выводим new_lines вместо old
                for (j = 1; j <= new_count; j++) {
                    print new_lines[j] > outfile
                }
                i += old_count
                continue
            }
        }
        
        # Не совпало или вне диапазона — выводим исходную строку
        print file_lines[i] > outfile
        i++
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