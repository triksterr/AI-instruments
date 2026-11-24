# Поиск и замена многострочных блоков в файле.
# old и new — многострочные блоки текста, читаемые из файлов.
# Использование без диапазона: awk-f replace-m.awk old.txt new.txt file.txt [outfile.txt]
# Использование с диапазоном: awk-f replace-m.awk old.txt new.txt start [end] file.txt [outfile.txt]
# old.txt — файл с искомым блоком
# new.txt — файл с новым блоком (пустой файл = удаление блока)
# start — начальная строка диапазона (от 1). Замена происходит, если ПЕРВАЯ строка блока находится в пределах [start, end].
# end — конечная строка диапазона (если не задана, проверяется только строка start)
# file.txt — исходный файл
# outfile.txt — имя файла для записи результата (если отсутствует — запись в исходный файл)

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется минимум 3 аргумента: old.txt new.txt file.txt" > "/dev/stderr"
        exit 1
    }
    
    # 1. Читаем имена файлов блоков (всегда ARGV[1] и ARGV[2])
    old_file = ARGV[1]
    new_file = ARGV[2]
    
    # Читаем old.txt в массив
    old_count = 0
    while ((getline line < old_file) > 0) {
        sub(/\r$/, "", line)
        old_count++
        old_lines[old_count] = line
    }
    close(old_file)
    
    if (old_count == 0) {
        print "Ошибка: old.txt пуст или не существует" > "/dev/stderr"
        exit 1
    }
    
    # Читаем new.txt в массив
    new_count = 0
    while ((getline line < new_file) > 0) {
        sub(/\r$/, "", line)
        new_count++
        new_lines[new_count] = line
    }
    close(new_file)
    
    # 2. Разбираем оставшиеся аргументы: start [end] file.txt [outfile.txt]
    # Проверяем, является ли ARGV[3] числом (начало диапазона)
    if (ARGV[3] ~ /^[0-9]+$/) {
        # Режим с диапазоном
        start = ARGV[3] + 0
        if (start < 1) {
            print "Ошибка: start должен быть >= 1" > "/dev/stderr"
            exit 1
        }
        
        if (ARGV[4] ~ /^[0-9]+$/) {
            # end задан
            end = ARGV[4] + 0
            input_file = ARGV[5]
            if (length(ARGV) >= 7) {
                target = ARGV[6]
            } else {
                target = input_file
            }
        } else {
            # end не задан
            end = start
            input_file = ARGV[4]
            if (length(ARGV) >= 6) {
                target = ARGV[5]
            } else {
                target = input_file
            }
        }
    } else {
        # Режим без диапазона
        start = 1
        end = 2147483647
        input_file = ARGV[3]
        if (length(ARGV) >= 5) {
            target = ARGV[4]
        } else {
            target = input_file
        }
    }
    
    if (input_file == "") {
        print "Ошибка: не указано имя входного файла" > "/dev/stderr"
        exit 1
    }
    
    # 3. Читаем весь входной файл в массив
    file_count = 0
    while ((getline line < input_file) > 0) {
        sub(/\r$/, "", line)
        file_count++
        file_lines[file_count] = line
    }
    close(input_file)
    
    # 4. Обрабатываем и записываем результат напрямую в target
    i = 1
    while (i <= file_count) {
        # Проверяем, начинается ли потенциальный блок в допустимом диапазоне
        if (i >= start && i <= end) {
            # Пытаемся сопоставить old_lines начиная с позиции i
            match_found = 1
            for (j = 1; j <= old_count; j++) {
                if (i + j - 1 > file_count) {
                    match_found = 0
                    break
                }
                if (file_lines[i + j - 1] != old_lines[j]) {
                    match_found = 0
                    break
                }
            }
            
            if (match_found) {
                # Выводим new_lines вместо old
                for (j = 1; j <= new_count; j++) {
                    print new_lines[j] > target
                }
                i += old_count
                continue
            }
        }
        
        # Не совпало или вне диапазона — выводим исходную строку
        print file_lines[i] > target
        i++
    }
    
    close(target)
    exit 0
}