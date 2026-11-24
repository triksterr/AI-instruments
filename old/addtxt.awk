# Добавление текста в конец файла БЕЗ перевода строки.
# Текст приклеивается к последнему символу файла.
# Если в конце файла был перевод строки — текст добавляется после него.
# Использование: awk-f addtxt.awk infile text [outfile]
# infile — исходный файл
# text — текст для добавления (без перевода строки)
# outfile — необязательный, если не задан — модификация infile in-place
# Кодировка сохраняется по исходному файлу

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется минимум 2 аргумента: infile text" > "/dev/stderr"
        exit 1
    }
    
    infile = ARGV[1]
    text = ARGV[2]
    
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
    
    # Читаем infile как единое целое для сохранения точной структуры
    RS = "^$"
    content = ""
    if ((getline content < infile) > 0) {
        printf "%s", content > outfile
    }
    close(infile)
    
    # Добавляем текст без перевода строки
    printf "%s", text > outfile
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