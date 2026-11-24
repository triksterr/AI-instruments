# test-awk-scripts.ps1
# Для запуска скопировать файл в корневую папку проекта
$ErrorActionPreference = "Stop"
$scriptDir = "C:\Users\Alex\Documents\prog\awk"
$testDir = Join-Path $scriptDir "test_temp"
$NL = [Environment]::NewLine

$script:passed = 0
$script:failed = 0

function Assert-FileEquals {
    param([string]$Path, [string[]]$ExpectedLines, [string]$TestName)
    if (-not (Test-Path $Path)) {
        Write-Host "[FAIL] $TestName (File not found: $Path)" -ForegroundColor Red
        $script:failed++; return
    }
    $actualLines = Get-Content $Path
    $expected = $ExpectedLines -join $NL
    $actual = ($actualLines -join $NL)
    if ($actual -eq $expected) {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        Write-Host "  Expected: $($ExpectedLines -join ', ')"
        Write-Host "  Actual:   $($actualLines -join ', ')"
        $script:failed++
    }
}

function Assert-OutputRegex {
    param([scriptblock]$Cmd, [string]$Pattern, [string]$TestName)
    $output = (& $Cmd 2>&1 | Out-String)
    # (?s) включает режим Singleline, чтобы точка . матчила символы новой строки \n
    if ($output -match "(?s)$Pattern") {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        Write-Host "  Regex: $Pattern"
        Write-Host "  Output: $output"
        $script:failed++
    }
}

function Assert-OutputContains {
    param([scriptblock]$Cmd, [string]$Text, [string]$TestName)
    $output = (& $Cmd 2>&1 | Out-String)
    if ($output.Contains($Text)) {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        Write-Host "  Expected to contain: $Text"
        $script:failed++
    }
}

function Assert-Exists {
    param([string]$Path, [string]$TestName)
    if (Test-Path $Path) {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host "[FAIL] $TestName (Not found: $Path)" -ForegroundColor Red
        $script:failed++
    }
}

if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
New-Item -ItemType Directory -Path $testDir | Out-Null
Push-Location $testDir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " AWK Scripts Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. cf
Write-Host "`n--- cf ---" -ForegroundColor Yellow
& "$scriptDir\cf.bat" empty.txt
Assert-Exists "empty.txt" "cf: empty file"

# 2. addline
Write-Host "`n--- addline ---" -ForegroundColor Yellow
Set-Content "t1.txt" -Value @("line1") -NoNewline
& "$scriptDir\addline.bat" t1.txt "line2"
Assert-FileEquals "t1.txt" @("line1", "line2") "addline: in-place"

# 3. addtxt
Write-Host "`n--- addtxt ---" -ForegroundColor Yellow
Set-Content "t2.txt" -Value @("line1") -NoNewline
& "$scriptDir\addtxt.bat" t2.txt "XXX"
Assert-FileEquals "t2.txt" @("line1XXX") "addtxt: in-place"

# 4. addfile
Write-Host "`n--- addfile ---" -ForegroundColor Yellow
Set-Content "f1.txt" -Value @("A") -NoNewline
Set-Content "f2.txt" -Value @("B") -NoNewline
& "$scriptDir\addfile.bat" f1.txt f2.txt out_f.txt
Assert-FileEquals "out_f.txt" @("AB") "addfile: outfile"

Set-Content "f1.txt" -Value @("A") -NoNewline
Set-Content "f2.txt" -Value @("B") -NoNewline
& "$scriptDir\addfile.bat" f1.txt f2.txt
Assert-FileEquals "f1.txt" @("AB") "addfile: in-place"

# 5. getline
Write-Host "`n--- getline ---" -ForegroundColor Yellow
Set-Content "gl.txt" -Value @("L1", "L2", "L3", "L4", "L5")
Assert-OutputRegex { & "$scriptDir\getline.bat" 2 4 gl.txt } "L2.*L3.*L4" "getline: range"
Assert-OutputContains { & "$scriptDir\getline.bat" 3 gl.txt } "L3" "getline: single"

# 6. delline
Write-Host "`n--- delline ---" -ForegroundColor Yellow
Set-Content "dl.txt" -Value @("L1", "L2", "L3", "L4", "L5")
& "$scriptDir\delline.bat" 2 4 dl.txt out_dl.txt
Assert-FileEquals "out_dl.txt" @("L1", "L5") "delline: range"

Set-Content "dl2.txt" -Value @("L1", "L2", "L3")
& "$scriptDir\delline.bat" 2 dl2.txt
Assert-FileEquals "dl2.txt" @("L1", "L3") "delline: single"

# 7. insline
Write-Host "`n--- insline ---" -ForegroundColor Yellow
Set-Content "il.txt" -Value @("L1", "L2", "L3")
& "$scriptDir\insline.bat" 2 "NEW" il.txt out_il.txt
Assert-FileEquals "out_il.txt" @("L1", "NEW", "L2", "L3") "insline: before"

Set-Content "il2.txt" -Value @("L1", "L2")
& "$scriptDir\insline.bat" 100 "END" il2.txt
Assert-FileEquals "il2.txt" @("L1", "L2", "END") "insline: end"

# 8. instxt
Write-Host "`n--- instxt ---" -ForegroundColor Yellow
Set-Content "it.txt" -Value @("L1", "abcdef", "L3")
& "$scriptDir\instxt.bat" 2 3 "XX" it.txt out_it.txt
Assert-FileEquals "out_it.txt" @("L1", "abXXcdef", "L3") "instxt: inside"

Set-Content "it2.txt" -Value @("L1", "short", "L3")
& "$scriptDir\instxt.bat" 2 100 "XX" it2.txt
Assert-FileEquals "it2.txt" @("L1", "shortXX", "L3") "instxt: end string"

Set-Content "it3.txt" -Value @("L1", "L2")
& "$scriptDir\instxt.bat" 100 5 "NEW" it3.txt
Assert-FileEquals "it3.txt" @("L1", "L2", "NEW") "instxt: new line"

# 9. inslines
Write-Host "`n--- inslines ---" -ForegroundColor Yellow
Set-Content "blk.txt" -Value @("B1", "B2")
Set-Content "ils.txt" -Value @("L1", "L2", "L3")
& "$scriptDir\inslines.bat" 2 blk.txt ils.txt out_ils.txt
Assert-FileEquals "out_ils.txt" @("L1", "B1", "B2", "L2", "L3") "inslines: block"

# 10. find-ln
Write-Host "`n--- find-ln ---" -ForegroundColor Yellow
Set-Content "fnd.txt" -Value @("apple", "banana", "apricot")
Assert-OutputRegex { & "$scriptDir\find-ln.bat" "ap" fnd.txt } "1.*3" "find-ln: nums"

# 11. find-pos
Write-Host "`n--- find-pos ---" -ForegroundColor Yellow
Set-Content "fnd.txt" -Value @("xxx ap xxx", "zzz", "ap ap")
Assert-OutputRegex { & "$scriptDir\find-pos.bat" "ap" fnd.txt } "1:5.*3:1,4" "find-pos: pos"

# 12. find-line
Write-Host "`n--- find-line ---" -ForegroundColor Yellow
Set-Content "fnd.txt" -Value @("apple", "banana", "apricot")
Assert-OutputContains { & "$scriptDir\find-line.bat" "ap" fnd.txt } "1:apple" "find-line: full"

# 13. replace
Write-Host "`n--- replace ---" -ForegroundColor Yellow
Set-Content "rep.txt" -Value @("old1", "old2", "keep")
& "$scriptDir\replace.bat" "old" "new" rep.txt out_rep.txt
Assert-FileEquals "out_rep.txt" @("new1", "new2", "keep") "replace: outfile"

Set-Content "rep2.txt" -Value @("old1", "old2", "keep")
& "$scriptDir\replace.bat" "old" "new" rep2.txt
Assert-FileEquals "rep2.txt" @("new1", "new2", "keep") "replace: in-place"

Set-Content "rep3.txt" -Value @("old1", "old2", "old3")
& "$scriptDir\replace.bat" "old" "new" 2 rep3.txt
Assert-FileEquals "rep3.txt" @("old1", "new2", "old3") "replace: single"

Set-Content "rep4.txt" -Value @("old1", "old2", "old3", "old4")
& "$scriptDir\replace.bat" "old" "new" 2 3 rep4.txt
Assert-FileEquals "rep4.txt" @("old1", "new2", "new3", "old4") "replace: range"

# 14. replace-m
Write-Host "`n--- replace-m ---" -ForegroundColor Yellow
Set-Content "old_b.txt" -Value @("O1", "O2")
Set-Content "new_b.txt" -Value @("N1")
Set-Content "repm.txt" -Value @("L1", "O1", "O2", "L4")
& "$scriptDir\replace-m.bat" old_b.txt new_b.txt repm.txt out_repm.txt
Assert-FileEquals "out_repm.txt" @("L1", "N1", "L4") "replace-m: block"

Pop-Location
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " RESULTS: $($script:passed) Passed, $($script:failed) Failed" -ForegroundColor $(if ($script:failed -eq 0) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Cyan