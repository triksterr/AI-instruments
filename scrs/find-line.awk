# Поиск подстроки в файле с выводом содержащих её строк целиком.
# Использование: awk-f find-line.awk string file.txt
# Вывод: номер_строки:вся_строка
# string — искомая подстрока (если содержит пробелы, заключайте в кавычки)

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется 2 аргумента: подстрока file.txt" > "/dev/stderr"
        exit 1
    }
    
    needle = ARGV[1]
    if (needle == "") {
        print "Ошибка: подстрока не может быть пустой" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
}

index($0, needle) > 0 {
    print NR ":" $0
}