# Вставка строки в файл.
# Использование: insline line_num text file.txt [outfile]
# Вставляет text как новую строку ПЕРЕД строкой с номером line_num
# line_num — номер строки (от 1). Если > числа строк — вставка в конец
# text — текст для вставки
# outfile — необязательный, если не задан — модификация in-place

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется 3 аргумента: line_num text file.txt" > "/dev/stderr"
        exit 1
    }
    
    # 1. Читаем все аргументы по их исходным индексам
    line_num = ARGV[1] + 0
    text = ARGV[2]
    input_file = ARGV[3]
    
    if (line_num < 1) {
        print "Ошибка: line_num должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    if (input_file == "") {
        print "Ошибка: не указано имя входного файла" > "/dev/stderr"
        exit 1
    }
    
    # 2. Определяем целевой файл (outfile или исходный)
    if (length(ARGV) >= 5) {
        target = ARGV[4]
    } else {
        target = input_file
    }
    
    # 3. Читаем весь входной файл в массив
    count = 0
    while ((getline line < input_file) > 0) {
        lines[++count] = line
    }
    close(input_file)
    
    # 4. Если line_num > count — вставляем в конец
    if (line_num > count + 1) {
        line_num = count + 1
    }
    
    # 5. Сдвигаем строки и вставляем новую
    for (i = count; i >= line_num; i--) {
        lines[i + 1] = lines[i]
    }
    lines[line_num] = text
    count++
    
    # 6. Записываем результат напрямую в target
    for (i = 1; i <= count; i++) {
        print lines[i] > target
    }
    close(target)
    
    exit 0
}