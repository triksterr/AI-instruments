# Склейка двух текстовых файлов в один с сохранением переводов строк.
# Использование: addfile one two [outfile]
# one — исходный файл (к которому добавляем)
# two — файл, содержимое которого добавляется в конец
# outfile — необязательный, если не задан — модификация one in-place
# Кодировка сохраняется по первому файлу (побайтовое копирование)

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется минимум 2 аргумента: one two" > "/dev/stderr"
        exit 1
    }
    
    # 1. Сначала сохраняем ВСЕ аргументы в переменные
    file_one = ARGV[1]
    file_two = ARGV[2]
    
    if (length(ARGV) >= 4) {
        outfile = ARGV[3]
        in_place = 0
    } else {
        outfile = file_one
        in_place = 1
    }
    
    # 2. Удаляем аргументы из ARGV, чтобы AWK не пытался открыть их как файлы для построчного чтения
    delete ARGV[1]
    delete ARGV[2]
    if (length(ARGV) >= 4) delete ARGV[3]
    
    # 3. Читаем оба файла как единое целое (сохраняем точную структуру переводов строк)
    RS = "^$"
    
    content_one = ""
    if ((getline content_one < file_one) > 0) {
    }
    close(file_one)
    
    content_two = ""
    if ((getline content_two < file_two) > 0) {
    }
    close(file_two)
    
    # 4. Записываем результат напрямую в целевой файл
    # Так как исходные файлы уже прочитаны и закрыты, перезапись file_one (при in_place) абсолютно безопасна
    printf "%s%s", content_one, content_two > outfile
    close(outfile)
    
    exit 0
}