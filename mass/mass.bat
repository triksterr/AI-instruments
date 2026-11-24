@echo off
powershell.exe -ExecutionPolicy Bypass -File "%~dp0mass-op.ps1" %*
pause