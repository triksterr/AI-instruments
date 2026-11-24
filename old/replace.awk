# Поиск и замена в файле - однострочная (блоки old и new - текст без перевода строки). 
# Использование: awk-f replace.awk old new file.txt [outfile.txt]
# old — что заменить (если содержит пробелы, заключайте в кавычки)
# new — на что заменить (если содержит пробелы, заключайте в кавычки) (пустая строка ("") = удаление)
# file.txt - исходный файл, в котором производится поиск (и замена, если не задан выходной файл)
# outfile.txt — имя файла для записи результата (необязательный, если отсутствует - запись в исходный файл)
# Пустой new ("") означает удаление подстроки (замена на пустую строку)

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
    
    # Сохраняем имя входного файла
    input_file = ARGV[1]
    
    # Определяем outfile (если задан)
    if (length(ARGV) >= 3) {
        outfile = ARGV[2]
        delete ARGV[2]
        in_place = 0
    } else {
        # In-place модификация
        in_place = 1
        temp_dir = ENVIRON["TEMP"]
        if (temp_dir == "") temp_dir = ENVIRON["TMP"]
        if (temp_dir == "") {
            print "Ошибка: не найдена переменная окружения TEMP/TMP" > "/dev/stderr"
            exit 1
        }
        outfile = temp_dir "\\awk_temp_" PROCINFO["pid"] ".tmp"
    }
}

{
    gsub(old, new)
    print > outfile
}

END {
    if (in_place) {
        close(outfile)
        cmd = "move /Y \"" outfile "\" \"" input_file "\" >nul 2>&1"
        result = system(cmd)
        if (result != 0) {
            print "Ошибка: не удалось заменить исходный файл" > "/dev/stderr"
            exit 1
        }
    }
}