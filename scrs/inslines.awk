# Вставка многострочного блока в файл
# Использование: awk-f inslines.awk line_num block.txt file.txt [outfile]
# Вставляет содержимое block.txt как новые строки ПЕРЕД строкой с номером line_num
# line_num — номер строки (от 1). Если line_num больше числа строк в файле — вставка в конец файла
# block.txt — файл с многострочным блоком для вставки (пустой файл ничего не вставит)
# file.txt — исходный файл
# outfile — необязательный, имя файла для записи результата, если не указан — запись в исходный файл

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется 3 аргумента: line_num block.txt file.txt" > "/dev/stderr"
        exit 1
    }
    
    line_num = ARGV[1] + 0
    block_file = ARGV[2]
    
    if (line_num < 1) {
        print "Ошибка: line_num должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
    delete ARGV[2]
    
    # Читаем block.txt в массив
    block_count = 0
    while ((getline line < block_file) > 0) {
        sub(/\r$/, "", line)
        block_count++
        block_lines[block_count] = line
    }
    close(block_file)
    
    # Определяем input_file и target
    input_file = ARGV[1]
    if (length(ARGV) >= 3) {
        target = ARGV[2]
        delete ARGV[2]
    } else {
        target = input_file
    }
    
    # Читаем весь входной файл в массив
    file_count = 0
    while ((getline line < input_file) > 0) {
        sub(/\r$/, "", line)
        file_count++
        file_lines[file_count] = line
    }
    close(input_file)
    
    # Корректируем line_num, если он больше числа строк
    if (line_num > file_count + 1) {
        line_num = file_count + 1
    }
    
    # Записываем результат напрямую в target
    for (i = 1; i <= file_count; i++) {
        if (i == line_num) {
            # Вставляем блок перед этой строкой
            for (j = 1; j <= block_count; j++) {
                print block_lines[j] > target
            }
        }
        print file_lines[i] > target
    }
    
    # Если line_num был больше числа строк — вставляем блок в конец
    if (line_num > file_count) {
        for (j = 1; j <= block_count; j++) {
            print block_lines[j] > target
        }
    }
    
    close(target)
    exit 0
}