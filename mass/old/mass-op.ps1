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
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Mode,
    
    [Parameter(Mandatory=$true)]
    [string]$Root,
    
    [Parameter(Mandatory=$true)]
    [string]$Mask,
    
    [Parameter(Mandatory=$true)]
    [string]$Command,
    
    [string]$NameMode = "none"
)

# Валидация режима
$validModes = @("f", "fr", "d", "dr")
if ($validModes -notcontains $Mode) {
    Write-Error "Неверный режим: $Mode`nДопустимо:`n  f  — файлы только в корневой папке`n  fr — файлы в дереве (рекурсивно)`n  d  — папки только в корневой папке`n  dr — папки в дереве (рекурсивно)"
    exit 1
}

# Проверка существования корневой папки
if (-not (Test-Path $Root)) {
    Write-Error "Корневая папка не существует: $Root"
    exit 1
}

# Абсолютный путь корня для корректного вычисления относительных путей
$Root = (Resolve-Path $Root).Path
if (-not $Root.EndsWith('\') -and -not $Root.EndsWith('/')) {
    $Root += '\'
}

# Валидация режима вывода имени
$validNameModes = @("none", "name", "rel", "abs")
if ($validNameModes -notcontains $NameMode) {
    Write-Error "Неверный режим вывода имени: $NameMode`nДопустимо: none, name, rel, abs"
    exit 1
}

# Получаем элементы согласно режиму
switch ($Mode) {
    "f" {
        $items = Get-ChildItem -Path $Root -File -Filter $Mask -ErrorAction SilentlyContinue
    }
    "fr" {
        $items = Get-ChildItem -Path $Root -File -Recurse -Filter $Mask -ErrorAction SilentlyContinue
    }
    "d" {
        $items = Get-ChildItem -Path $Root -Directory -ErrorAction SilentlyContinue
    }
    "dr" {
        $items = Get-ChildItem -Path $Root -Directory -Recurse -ErrorAction SilentlyContinue
    }
}

# Обработка каждого элемента
$processedCount = 0
foreach ($item in $items) {
    $abs = $item.FullName
    $name = $item.Name
    
    # Относительный путь (от корня)
    if ($abs.StartsWith($Root)) {
        $rel = $abs.Substring($Root.Length)
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
    switch ($NameMode) {
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