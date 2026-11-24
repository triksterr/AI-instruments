# Поиск подстроки в файле с выводом номеров строк, где она найдена. 
# Использование: ./awk-f find-ln.awk string file.txt
# string — искомая подстрока (если содержит пробелы, заключайте её в кавычки)

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется 2 аргумента: string file.txt" > "/dev/stderr"
		print "Если искомая подстрока содержит пробелы, заключайте её в кавычки"
        exit 1
    }
    
    needle = ARGV[1]
    if (needle == "") {
        print "Ошибка: искомая подстрока не может быть пустой" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
}

index($0, needle) > 0 {
    print NR
}