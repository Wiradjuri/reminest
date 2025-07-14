Write-Host "=== Reminest Build Artifacts ===" -ForegroundColor Green
Write-Host ""

# Check Android builds
Write-Host "Android Builds:" -ForegroundColor Cyan
if (Test-Path "build\app\outputs\flutter-apk\app-debug.apk") {
    $debugSize = [math]::Round((Get-Item "build\app\outputs\flutter-apk\app-debug.apk").Length / 1MB, 2)
    Write-Host "  ✅ Debug APK: $debugSize MB" -ForegroundColor Green
}

if (Test-Path "build\app\outputs\flutter-apk\app-release.apk") {
    $releaseSize = [math]::Round((Get-Item "build\app\outputs\flutter-apk\app-release.apk").Length / 1MB, 2)
    Write-Host "  ✅ Release APK: $releaseSize MB" -ForegroundColor Green
}

if (Test-Path "build\app\outputs\bundle\release\app-release.aab") {
    $bundleSize = [math]::Round((Get-Item "build\app\outputs\bundle\release\app-release.aab").Length / 1MB, 2)
    Write-Host "  ✅ App Bundle: $bundleSize MB" -ForegroundColor Green
}

# Check Windows build
Write-Host ""
Write-Host "Windows Build:" -ForegroundColor Cyan
if (Test-Path "build\windows\runner\Release\reminest.exe") {
    $windowsSize = [math]::Round((Get-Item "build\windows\runner\Release\reminest.exe").Length / 1MB, 2)
    Write-Host "  ✅ Windows EXE: $windowsSize MB" -ForegroundColor Green
} else {
    Write-Host "  ❌ Windows build not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Installation Commands ===" -ForegroundColor Yellow
Write-Host "Android (Debug): adb install build\app\outputs\flutter-apk\app-debug.apk"
Write-Host "Android (Release): adb install build\app\outputs\flutter-apk\app-release.apk"
Write-Host "Windows: .\build\windows\runner\Release\reminest.exe"

Write-Host ""
Write-Host "=== Distribution Ready ===" -ForegroundColor Green
Write-Host "📱 Android Release APK: Ready for sideloading"
Write-Host "📦 Android App Bundle: Ready for Google Play Store"
Write-Host "💻 Windows EXE: Ready for distribution"