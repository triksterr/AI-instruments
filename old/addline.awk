# Добавление строки с переводом строки в конец файла.
# Использование: awk-f addline.awk infile string [outfile]
# infile — исходный файл
# string — строка для добавления (если "" — добавляется просто перевод строки)
# outfile — необязательный, если не задан — модификация infile in-place
# Кодировка сохраняется по исходному файлу

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется минимум 2 аргумента: infile string" > "/dev/stderr"
        exit 1
    }
    
    infile = ARGV[1]
    string = ARGV[2]
    
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
    
    # Копируем infile в outfile построчно
    while ((getline line < infile) > 0) {
        print line > outfile
    }
    close(infile)
    
    # Добавляем строку с переводом строки (print автоматически добавляет ORS)
    print string > outfile
    close(outfile)
    
    if (in_place) {
        cmd = "move /Y \"" outfile "\" \"" infile "\" >nul 2>&1"
        result = system(cmd)
        if (result != 0) {
            print "Ошибка: не удалось заменить исходный файл" > "/dev/stderr"
            exit 1
        }
    }
    exit 0
}