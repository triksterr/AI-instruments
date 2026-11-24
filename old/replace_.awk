# Поиск и замена в файле с опциональным указанием диапазона строк.
# Использование без диапазона: awk-f replace.awk old new file.txt [outfile.txt]
# Использование с диапазоном: awk-f replace.awk old new start [end] file.txt [outfile.txt]
# 
# old — что заменить (если содержит пробелы, заключайте в кавычки)
# new — на что заменить (если содержит пробелы, заключайте в кавычки) (пустая строка ("") = удаление)
# start — начальная строка диапазона (от 1)
# end — конечная строка диапазона (если не задана, заменяется только в строке start)
# file.txt - исходный файл
# outfile.txt — имя файла для записи результата (если отсутствует - запись в исходный файл)

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется минимум 3 аргумента: old new file.txt" > "/dev/stderr"
        print "Или с диапазоном: old new start [end] file.txt [outfile.txt]" > "/dev/stderr"
        exit 1
    }
    
    old = ARGV[1]
    new = ARGV[2]
    
    if (old == "") {
        print "Ошибка: old не может быть пустым" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
    delete ARGV[2]
    
    # Проверяем, является ли следующий аргумент числом (начало диапазона)
    if (ARGV[1] ~ /^[0-9]+$/) {
        # Режим с диапазоном: old new start [end] file.txt [outfile]
        start = ARGV[1] + 0
        delete ARGV[1]
        
        if (start < 1) {
            print "Ошибка: start должен быть >= 1" > "/dev/stderr"
            exit 1
        }
        
        # Проверяем, является ли следующий аргумент тоже числом (end)
        if (ARGV[2] ~ /^[0-9]+$/) {
            end = ARGV[2] + 0
            delete ARGV[2]
        } else {
            # Если end не задан, заменяем только в одной строке
            end = start
        }
        
        # Теперь ARGV[1] должен быть именем входного файла
        input_file = ARGV[1]
        
        # Проверяем наличие outfile
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
        # Режим без диапазона: old new file.txt [outfile]
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
    
    # Создаём пустой временный файл
    printf "" > outfile
}

{
    # Заменяем только в указанном диапазоне строк
    if (NR >= start && NR <= end) {
        gsub(old, new)
    }
    print > outfile
}

END {
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