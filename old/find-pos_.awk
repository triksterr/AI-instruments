# Поиск подстроки в файле с выводом мест(строка-столбец), где она найдена. 
# Использование: awk-f find-pos.awk string file.txt
# Вывод: номер_строки:позиция1,позиция2,...
# string — искомая подстрока (если содержит пробелы, заключайте её в кавычки)

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется 2 аргумента: string file.txt" > "/dev/stderr"
        exit 1
    }
    
    needle = ARGV[1]
    if (needle == "") {
        print "Ошибка: строка не может быть пустой" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
}

{
    pos = 1
    positions = ""
    line = $0
    while ((idx = index(substr(line, pos), needle)) > 0) {
        actual_pos = pos + idx - 1
        positions = positions (positions == "" ? "" : ",") actual_pos
        pos = actual_pos + length(needle)
    }
    if (positions != "") {
        print NR ":" positions
    }
}