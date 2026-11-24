# Поиск и замена в файле - однострочная.
# Использование без диапазона: awk-f replace.awk old new file.txt [outfile.txt]
# Использование с диапазоном: awk-f replace.awk old new start [end] file.txt [outfile.txt]
#
# old — что заменить (если содержит пробелы, заключайте в кавычки)
# new — на что заменить (пустая строка ("") = удаление)
# start — начальная строка диапазона (от 1)
# end — конечная строка диапазона (если не задана, заменяется только в строке start)
# file.txt — исходный файл
# outfile.txt — имя файла для записи результата (если отсутствует — запись в исходный файл)

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется минимум 3 аргумента: old new file.txt" > "/dev/stderr"
        print "Или с диапазоном: old new start [end] file.txt [outfile.txt]" > "/dev/stderr"
        exit 1
    }
    
    old = ARGV[1]
    new = ARGV[2]
    
    if (old == "") {
        print "Ошибка: old не может быть пустым" > "/dev/stderr"
        exit 1
    }
    
    delete ARGV[1]
    delete ARGV[2]
    
    # Определяем режим: с диапазоном или без
    if (ARGV[1] ~ /^[0-9]+$/) {
        # Режим с диапазоном: old new start [end] file.txt [outfile]
        start = ARGV[1] + 0
        delete ARGV[1]
        
        if (start < 1) {
            print "Ошибка: start должен быть >= 1" > "/dev/stderr"
            exit 1
        }
        
        # Проверяем, является ли следующий аргумент числом (end)
        if (ARGV[1] ~ /^[0-9]+$/) {
            end = ARGV[1] + 0
            delete ARGV[1]
        } else {
            # Если end не задан, заменяем только в одной строке
            end = start
        }
        
        # Теперь ARGV[1] должен быть именем входного файла
        input_file = ARGV[1]
        delete ARGV[1]
        
        # Проверяем наличие outfile
        if (length(ARGV) >= 2) {
            target = ARGV[1]
        } else {
            target = input_file
        }
    } else {
        # Режим без диапазона: old new file.txt [outfile]
        start = 1
        end = 2147483647
        
        input_file = ARGV[1]
        delete ARGV[1]
        
        if (length(ARGV) >= 2) {
            target = ARGV[1]
        } else {
            target = input_file
        }
    }
    
    # Читаем весь файл в массив
    count = 0
    while ((getline line < input_file) > 0) {
        lines[++count] = line
    }
    close(input_file)
    
    # Обрабатываем строки в заданном диапазоне
    for (i = 1; i <= count; i++) {
        if (i >= start && i <= end) {
            gsub(old, new, lines[i])
        }
    }
    
    # Записываем результат напрямую в target
    for (i = 1; i <= count; i++) {
        print lines[i] > target
    }
    close(target)
    
    exit 0
}