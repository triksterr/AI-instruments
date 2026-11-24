<#
.SYNOPSIS
    Массовое выполнение команды над файлами или папками в дереве каталогов.
.DESCRIPTION
    Обходит указанную папку и выполняет заданную команду для каждого файла/папки.
    В команде доступны плейсхолдеры:
        {}     — полный путь
        {n}    — только имя (с расширением для файлов)
        {nb}   — имя без расширения (только для файлов)
        {ext}  — расширение с точкой (только для файлов)
        {r}    — относительный путь (от корня)
        {d}    — директория (путь без имени)
.PARAMETER mode
    Режим обхода (по умолчанию: fr):
      f  — файлы только в корневой папке
      fr — файлы в дереве (рекурсивно)
      d  — папки только в корневой папке
      dr — папки в дереве (рекурсивно)
.PARAMETER root
    Корневая папка (по умолчанию: текущая папка)
.PARAMETER mask
    Маска файлов/папок (по умолчанию: *.*)
.PARAMETER names
    Режим вывода имени (по умолчанию: none):
      none — не выводить
      name — только имя
      rel  — относительный путь от корня
      abs  — абсолютный путь
#>

param(
    [string]$mode = "fr",
    [string]$root = ".",
    [string]$mask = "*.*",
    [string]$names = "none",
    
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$CommandArgs
)

# Склеиваем остаточные аргументы в одну строку команды
$Command = ($CommandArgs -join ' ')

# Валидация команды
if ([string]::IsNullOrWhiteSpace($Command)) {
    Write-Error "Не указана команда для выполнения"
    exit 1
}

# Валидация режима
$validModes = @("f", "fr", "d", "dr")
if ($validModes -notcontains $mode) {
    Write-Error "Неверный режим: $mode`nДопустимо: f, fr, d, dr"
    exit 1
}

# Проверка существования корневой папки
if (-not (Test-Path $root)) {
    Write-Error "Корневая папка не существует: $root"
    exit 1
}

# Абсолютный путь корня для корректного вычисления относительных путей
$root = (Resolve-Path $root).Path
if (-not $root.EndsWith('\') -and -not $root.EndsWith('/')) {
    $root += '\'
}

# Валидация режима вывода имени
$validNameModes = @("none", "name", "rel", "abs")
if ($validNameModes -notcontains $names) {
    Write-Error "Неверный режим вывода имени: $names`nДопустимо: none, name, rel, abs"
    exit 1
}

# Получаем элементы согласно режиму
switch ($mode) {
    "f" {
        $items = Get-ChildItem -Path $root -File -Filter $mask -ErrorAction SilentlyContinue
    }
    "fr" {
        $items = Get-ChildItem -Path $root -File -Recurse -Filter $mask -ErrorAction SilentlyContinue
    }
    "d" {
        $items = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue
    }
    "dr" {
        $items = Get-ChildItem -Path $root -Directory -Recurse -ErrorAction SilentlyContinue
    }
}

# Обработка каждого элемента
$processedCount = 0
foreach ($item in $items) {
    $abs = $item.FullName
    $name = $item.Name
    
    # Относительный путь (от корня)
    if ($abs.StartsWith($root)) {
        $rel = $abs.Substring($root.Length)
    } else {
        $rel = $abs
    }
    
    # Директория
    if ($item.PSIsContainer) {
        $dir = Split-Path $abs -Parent
    } else {
        $dir = $item.DirectoryName
    }
    
    # Имя без расширения и расширение (только для файлов)
    if ($item.PSIsContainer) {
        $nb = $name
        $ext = ""
    } else {
        $nb = [System.IO.Path]::GetFileNameWithoutExtension($name)
        $ext = [System.IO.Path]::GetExtension($name)
    }
    
    # Вывод имени (если запрошено)
    switch ($names) {
        "name" {
            Write-Host "`n===== [$name] =====" -ForegroundColor Cyan
        }
        "rel" {
            Write-Host "`n===== [$rel] =====" -ForegroundColor Cyan
        }
        "abs" {
            Write-Host "`n===== [$abs] =====" -ForegroundColor Cyan
        }
    }
    
    # Подстановка плейсхолдеров в команде
    $cmd = $Command
    $cmd = $cmd.Replace('{}', $abs)
    $cmd = $cmd.Replace('{n}', $name)
    $cmd = $cmd.Replace('{nb}', $nb)
    $cmd = $cmd.Replace('{ext}', $ext)
    $cmd = $cmd.Replace('{r}', $rel)
    $cmd = $cmd.Replace('{d}', $dir)
    
    # Выполнение команды через cmd /c для совместимости с CMD-командами
    cmd /c $cmd
    
    $processedCount++
}

Write-Host "`nОбработано элементов: $processedCount" -ForegroundColor Green