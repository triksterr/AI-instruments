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
    
    # Определяем целевой файл
    if (length(ARGV) >= 2) {
        target = ARGV[1]
    } else {
        target = file_one
    }
    
    # Читаем оба файла как единое целое (сохраняем точную структуру)
    RS = "^$"
    
    content_one = ""
    if ((getline content_one < file_one) > 0) {
    }
    close(file_one)
    
    content_two = ""
    if ((getline content_two < file_two) > 0) {
    }
    close(file_two)
    
    # Записываем результат в целевой файл
    printf "%s%s", content_one, content_two > target
    close(target)
    
    exit 0
}