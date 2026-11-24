@REM создание пустого файла с именем
@echo off
IF "%~1"=="" ( exit /b 1 )
type nul > %1