# Поиск и замена в файле - однострочная.
# Использование: awk-f replace.awk old new file.txt [outfile.txt]
# old — что заменить
# new — на что заменить (пустая строка = удаление)
# file.txt — исходный файл
# outfile.txt — необязательный, если не задан — модификация in-place

BEGIN {
    if (length(ARGV) < 4) {
        print "Ошибка: требуется минимум 3 аргумента: old new file.txt" > "/dev/stderr"
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
    
    # Обрабатываем
    for (i = 1; i <= count; i++) {
        gsub(old, new, lines[i])
    }
    
    # Записываем обратно
    for (i = 1; i <= count; i++) {
        print lines[i] > target
    }
    close(target)
    
    exit 0
}