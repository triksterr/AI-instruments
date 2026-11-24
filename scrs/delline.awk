# Удаление одной или нескольких строк из файла
# Использование: delline start [end] file.txt [outfile.txt]
# start — начальный номер строки (от 1)
# end — конечный номер (если не задан, удаляется одна строка)
# file.txt - исходный файл (в котором производится удаление, если не задан выходной файл)
# outfile.txt — необязательный, имя файла для записи результата в другой файл

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется минимум 2 аргумента: start file.txt" > "/dev/stderr"
        exit 1
    }
    
    # 1. Читаем start (всегда ARGV[1])
    start = ARGV[1] + 0
    if (start < 1) {
        print "Ошибка: start должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    # 2. Определяем, задан ли end (проверяем ARGV[2])
    if (ARGV[2] ~ /^[0-9]+$/) {
        # Режим с диапазоном: start end file.txt [outfile]
        end = ARGV[2] + 0
        input_file = ARGV[3]
        
        if (length(ARGV) >= 5) {
            target = ARGV[4]
        } else {
            target = input_file
        }
    } else {
        # Режим без end: start file.txt [outfile]
        end = start
        input_file = ARGV[2]
        
        if (length(ARGV) >= 4) {
            target = ARGV[3]
        } else {
            target = input_file
        }
    }
    
    if (input_file == "") {
        print "Ошибка: не указано имя входного файла" > "/dev/stderr"
        exit 1
    }
    
    # 3. Читаем весь файл в массив
    count = 0
    while ((getline line < input_file) > 0) {
        lines[++count] = line
    }
    close(input_file)
    
    # 4. Записываем строки, не попадающие в диапазон [start, end]
    new_count = 0
    for (i = 1; i <= count; i++) {
        if (i < start || i > end) {
            new_lines[++new_count] = lines[i]
        }
    }
    
    # 5. Записываем обратно напрямую в target
    for (i = 1; i <= new_count; i++) {
        print new_lines[i] > target
    }
    close(target)
    
    exit 0
}