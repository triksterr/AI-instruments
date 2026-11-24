@REM Запуск awk.exe с аргументами с кодировкой файлов UTF-8
@set LC_ALL=C.UTF-8
@set LANG=C.UTF-8
@chcp 65001 > nul
@%~dp0..\awk\awk.exe %*
@REM pause