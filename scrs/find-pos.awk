# Поиск подстроки в файле с выводом мест(строка:позиции), где она найдена. 
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
    
    needle_len = length(needle)
    delete ARGV[1]
}

{
    positions = ""
    char_pos = 1
    i = 1
    line_len = length($0)
    
    while (i <= line_len) {
        # Вырезаем needle_len символов начиная с позиции i
        candidate = substr($0, i, needle_len)
        
        if (candidate == needle) {
            positions = positions (positions == "" ? "" : ",") char_pos
            # Пропускаем всю найденную подстроку
            i += needle_len
            char_pos += needle_len
        } else {
            # Переходим к следующему символу
            i += 1
            char_pos += 1
        }
    }
    
    if (positions != "") {
        print NR ":" positions
    }
}