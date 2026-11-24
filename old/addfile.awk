# Склейка двух текстовых файлов в один с сохранением переводов строк.
# Использование: awk-f addfile.awk one two [outfile]
# one — исходный файл (к которому добавляем)
# two — файл, содержимое которого добавляется в конец
# outfile — необязательный, если не задан — модификация one in-place
# Кодировка сохраняется по первому файлу (побайтовое копирование)

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется минимум 2 аргумента: one two" > "/dev/stderr"
        exit 1
    }
    
    file_one = ARGV[1]
    file_two = ARGV[2]
    
    delete ARGV[1]
    delete ARGV[2]
    
    if (length(ARGV) >= 2) {
        outfile = ARGV[1]
        delete ARGV[1]
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
    
    # Читаем оба файла как единое целое для сохранения точной структуры переводов строк
    RS = "^$"  # Специальное значение RS для чтения всего файла как одной записи
    
    # Копируем file_one
    if ((getline content < file_one) > 0) {
        printf "%s", content > outfile
    }
    close(file_one)
    
    # Добавляем file_two
    if ((getline content < file_two) > 0) {
        printf "%s", content > outfile
    }
    close(file_two)
    
    if (in_place) {
        close(outfile)
        cmd = "move /Y \"" outfile "\" \"" file_one "\" >nul 2>&1"
        result = system(cmd)
        if (result != 0) {
            print "Ошибка: не удалось заменить исходный файл" > "/dev/stderr"
            exit 1
        }
    }
    exit 0
}