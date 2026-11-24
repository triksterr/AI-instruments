# Удаление одной или нескольких строк из файла
# Использование: awk-f delline.awk start [end] file.txt [outfile.txt]
# start — начальный номер строки (от 1)
# end — конечный номер (если не задан, удаляется одна строка)
# file.txt - исходный файл (в котором производится удаление, если не задан выходной файл)
# outfile.txt — необязательный, имя файла для записи результата в другой файл

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется минимум 2 аргумента: start file.txt" > "/dev/stderr"
        exit 1
    }
    
    start = ARGV[1] + 0
    if (start < 1) {
        print "Ошибка: start должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
    
    # Сохраняем имя входного файла
    input_file = ARGV[1]
    
    # Определяем end и outfile
    if (ARGV[2] ~ /^[0-9]+$/) {
        end = ARGV[2] + 0
        delete ARGV[2]
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
    } else {
        end = start
        # outfile, если есть
        if (ARGV[2] != "" && !(ARGV[2] ~ /^[0-9]+$/)) {
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
    
    # Принудительно создаём пустой временный файл.
    # Это нужно на случай, если удаляются вообще все строки (тогда print > outfile не сработает ни разу)
    printf "" > outfile
}

NR < start || NR > end {
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