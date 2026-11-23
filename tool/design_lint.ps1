# UniBite Design System Linter for Windows PowerShell
Write-Host "=== UniBite Design Linter ===" -ForegroundColor Cyan

$failures = 0

# Check for stock Colors.* usage outside design_system and transparent
Write-Host "1. Checking for raw Colors.* usage outside design_system..."
$rawColors = Get-ChildItem -Path lib -Recurse -Filter *.dart | 
    Where-Object { $_.FullName -notmatch "design_system" } | 
    Select-String -CaseSensitive -Pattern "(?<![A-Za-z0-9_])Colors\.(?!transparent)"
if ($rawColors) {
    Write-Host "[FAIL] Found unauthorized Colors.* usage:" -ForegroundColor Red
    $rawColors | ForEach-Object { Write-Host "$($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
    $failures++
} else {
    Write-Host "[PASS] No unauthorized stock Colors.* found." -ForegroundColor Green
}

# Check for raw Color(0x...) hex literals outside design_system
Write-Host "2. Checking for raw Color(0x...) hex literals outside design_system..."
$rawHex = Get-ChildItem -Path lib -Recurse -Filter *.dart | 
    Where-Object { $_.FullName -notmatch "design_system" } | 
    Select-String -CaseSensitive -Pattern "(?<![A-Za-z0-9_])Color\(0x"
if ($rawHex) {
    Write-Host "[FAIL] Found unauthorized raw Color(0x...) literals:" -ForegroundColor Red
    $rawHex | ForEach-Object { Write-Host "$($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
    $failures++
} else {
    Write-Host "[PASS] No raw hex Color literals found." -ForegroundColor Green
}

# Check for LinearProgressIndicator usage (strict circular requirement)
Write-Host "3. Checking for LinearProgressIndicator (must be circular AppLoader)..."
$linearLoaders = Get-ChildItem -Path lib -Recurse -Filter *.dart | 
    Select-String -CaseSensitive -Pattern "LinearProgressIndicator"
if ($linearLoaders) {
    Write-Host "[FAIL] Found LinearProgressIndicator usage (only circular AppLoader permitted):" -ForegroundColor Red
    $linearLoaders | ForEach-Object { Write-Host "$($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
    $failures++
} else {
    Write-Host "[PASS] All progress indicators adhere to circular standard." -ForegroundColor Green
}

if ($failures -gt 0) {
    Write-Host "=== Design lint FAILED with $failures issues ===" -ForegroundColor Red
    exit 1
}

Write-Host "=== Design lint PASSED (100% token compliant) ===" -ForegroundColor Green
exit 0
