# Добавление строки с переводом строки в конец файла.
# Использование: awk-f addline.awk infile string [outfile]
# infile — исходный файл
# string — строка для добавления (если "" — просто перевод строки)
# outfile — необязательный, если не задан — модификация infile in-place

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
    
    # Определяем, чем заканчивается исходный файл
    needs_newline = 0
    if (length(content) > 0) {
        last_char = substr(content, length(content), 1)
        if (last_char != "\n" && last_char != "\r") {
            needs_newline = 1
        }
    }
    
    # Формируем новое содержимое
    if (needs_newline) {
        new_content = content "\n" string "\n"
    } else {
        new_content = content string "\n"
    }
    
    printf "%s", new_content > target
    close(target)
    
    exit 0
}