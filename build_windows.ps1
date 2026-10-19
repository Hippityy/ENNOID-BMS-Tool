Write-Host "============================================="
Write-Host "   Building ENNOID-BMS-Tool for Windows"
Write-Host "============================================="

# 1. Run qmake
qmake "CONFIG-=build_mobile" "CONFIG+=release" ENNOID-BMS-Tool.pro
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 2. Compile with nmake (enable parallel compilation across all CPU cores)
$env:CL = "/MP"
nmake release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 3. Locate executable
$exe = (Get-ChildItem -Path . -Recurse -Filter "ENNOID-BMS-Tool*.exe").FullName | Select-Object -First 1
if (-not $exe) {
    Write-Error "Could not find built ENNOID-BMS-Tool*.exe"
    exit 1
}
Write-Host "Found binary: $exe"

# 4. Packaging
$deployDir = "ENNOID-BMS-Tool-Windows"
if (Test-Path $deployDir) { Remove-Item -Recurse -Force $deployDir }
New-Item -ItemType Directory -Path $deployDir | Out-Null
Copy-Item $exe -Destination "$deployDir\ENNOID-BMS-Tool.exe"

# Run windeployqt
windeployqt --release --qmldir mobile "$deployDir\ENNOID-BMS-Tool.exe"

# Compress to zip
Compress-Archive -Path "$deployDir" -DestinationPath "ENNOID-BMS-Tool-Windows-x64.zip" -Force
Write-Host "Generated: ENNOID-BMS-Tool-Windows-x64.zip"
Write-Host "============================================="
Write-Host "   Windows build completed successfully!"
Write-Host "============================================="
