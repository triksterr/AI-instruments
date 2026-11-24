# Вывод диапазона строк из файла.
# Использование: awk-f getline.awk start [end] file.txt
# start — начальный номер строки (от 1)
# end — конечный номер (если не задан, выводится одна строка)

BEGIN {
    if (length(ARGV) < 3) {
        print "Ошибка: требуется минимум 2 аргумента: start file.txt" > "/dev/stderr"
        print "Использование: awk-f getline.awk start [end] file.txt" > "/dev/stderr"
        exit 1
    }
    
    start = ARGV[1] + 0
    if (start < 1) {
        print "Ошибка: start должен быть >= 1" > "/dev/stderr"
        exit 1
    }
    
    # Если второй аргумент — число, то это end; иначе это файл
    if (ARGV[2] ~ /^[0-9]+$/) {
        end = ARGV[2] + 0
        delete ARGV[1]
        delete ARGV[2]
    } else {
        end = start
        delete ARGV[1]
    }
}

NR >= start && NR <= end {
    print
}