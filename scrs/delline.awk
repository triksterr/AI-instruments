# Удаление одной или нескольких строк из файла
# Использование: awk-f delline.awk start [end] file.txt [outfile.txt]
# start — начальный номер строки (от 1)
# end — конечный номер (если не задан, удаляется одна строка)
# file.txt - исходный файл (в котором производится удаление, если не задан выходной файл)
# outfile.txt — необязательный, имя файла для записи результата в другой файл

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется минимум 2 аргумента: start file.txt" > "/dev/stderr"
        exit 1
    }
    
    start = ARGV[1] + 0
    if (start < 1) {
        print "Ошибка: start должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
    
    # Определяем end
    if (ARGV[1] ~ /^[0-9]+$/) {
        end = ARGV[1] + 0
        delete ARGV[1]
    } else {
        end = start
    }
    
    input_file = ARGV[1]
    
    if (length(ARGV) >= 3) {
        target = ARGV[2]
        delete ARGV[2]
    } else {
        target = input_file
    }
    
    # Читаем весь файл в массив
    count = 0
    while ((getline line < input_file) > 0) {
        lines[++count] = line
    }
    close(input_file)
    
    # Записываем строки, не попадающие в диапазон [start, end]
    new_count = 0
    for (i = 1; i <= count; i++) {
        if (i < start || i > end) {
            new_lines[++new_count] = lines[i]
        }
    }
    
    # Записываем обратно
    for (i = 1; i <= new_count; i++) {
        print new_lines[i] > target
    }
    close(target)
    
    exit 0
}