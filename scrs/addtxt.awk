# Добавление текста в конец файла БЕЗ перевода строки.
# Текст приклеивается к последнему символу файла.
# Использование: awk-f addtxt.awk infile text [outfile]
# infile — исходный файл
# text — текст для добавления
# outfile — необязательный, если не задан — модификация infile in-place

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
        target = ARGV[1]
    } else {
        target = infile
    }
    
    # Читаем infile как единое целое
    RS = "^$"
    content = ""
    if ((getline content < infile) > 0) {
    }
    close(infile)
    
    # Просто дописываем текст в конец
    printf "%s%s", content, text > target
    close(target)
    
    exit 0
}