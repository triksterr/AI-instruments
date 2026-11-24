# Вставка текста в строку
# Использование: awk-f instxt.awk line_num pos text file.txt [outfile]
# Вставляет text ВНУТРЬ строки line_num на позицию pos (символы сдвигаются)
# Если pos больше длины строки — вставка в конец строки
# line_num — номер строки (от 1). Если line_num больше числа строк — добавляется новая строка в конец файла
# pos — позиция вставки (от 1). Если pos больше длины строки — вставка в конец строки
# text — текст для вставки (если содержит пробелы, заключайте в кавычки)
# outfile — необязательный, имя файла для записи результата, если не указан — запись в исходный файл

BEGIN {
    if (length(ARGV) < 5) {
        print "Ошибка: требуется 4 аргумента: line_num pos text file.txt" > "/dev/stderr"
        exit 1
    }
    
    # 1. Читаем все аргументы по их исходным индексам
    line_num = ARGV[1] + 0
    pos = ARGV[2] + 0
    text = ARGV[3]
    
    if (line_num < 1) {
        print "Ошибка: line_num должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    if (pos < 1) {
        print "Ошибка: pos должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    # 2. Определяем input_file и target (без delete ARGV)
    input_file = ARGV[4]
    
    if (length(ARGV) >= 6) {
        target = ARGV[5]
    } else {
        target = input_file
    }
    
    # 3. Читаем весь входной файл в массив
    file_count = 0
    while ((getline line < input_file) > 0) {
        sub(/\r$/, "", line)
        file_count++
        file_lines[file_count] = line
    }
    close(input_file)
    
    # 4. Определяем, что делать
    if (line_num > file_count) {
        # Добавляем новую строку в конец файла
        file_count++
        file_lines[file_count] = text
    } else {
        # Модифицируем существующую строку
        line_len = length(file_lines[line_num])
        if (pos > line_len) {
            # Вставка в конец строки
            file_lines[line_num] = file_lines[line_num] text
        } else {
            # Вставка в середину строки
            file_lines[line_num] = substr(file_lines[line_num], 1, pos - 1) text substr(file_lines[line_num], pos)
        }
    }
    
    # 5. Записываем результат напрямую в target
    for (i = 1; i <= file_count; i++) {
        print file_lines[i] > target
    }
    close(target)
    
    exit 0
}