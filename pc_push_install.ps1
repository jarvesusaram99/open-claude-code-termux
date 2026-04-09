# =========================================================================
#  OpenClaude God-Mode - One-Click PC Installer
#  Run on Windows PC with phone connected via USB.
#  Prerequisite: USB Debugging enabled on the phone.
# =========================================================================

Write-Host ""
Write-Host "  ======================================================" -ForegroundColor Cyan
Write-Host "    OpenClaude God-Mode - PC Push Installer" -ForegroundColor Cyan
Write-Host "    Fully automated. Zero manual steps." -ForegroundColor Cyan
Write-Host "  ======================================================" -ForegroundColor Cyan
Write-Host ""

# -- Step 0: Check ADB --
Write-Host "  [0/7] Checking ADB..." -ForegroundColor Magenta
$device = adb devices 2>&1 | Select-String "device$"
if (-not $device) {
    Write-Host "  X No device found! Enable USB Debugging and reconnect." -ForegroundColor Red
    Write-Host "    Settings > About Phone > Tap Build Number 7x > Developer Options > USB Debugging ON" -ForegroundColor DarkGray
    exit 1
}
$serial = ($device -split "\s+")[0]
Write-Host "  OK Device connected: $serial" -ForegroundColor Green

# -- Step 1: Install APKs --
Write-Host ""
Write-Host "  [1/7] Installing required Android apps..." -ForegroundColor Magenta

$termux = adb shell pm list packages com.termux 2>&1
if ($termux -match "com.termux") {
    Write-Host "  OK Termux already installed" -ForegroundColor Green
} else {
    Write-Host "  .. Termux not found. Downloading from GitHub..." -ForegroundColor Blue
    $termuxUrl = "https://github.com/termux/termux-app/releases/download/v0.118.1/termux-app_v0.118.1+github-debug_arm64-v8a.apk"
    Invoke-WebRequest -Uri $termuxUrl -OutFile "$env:TEMP\termux.apk" -UseBasicParsing
    adb install "$env:TEMP\termux.apk"
    Write-Host "  OK Termux installed" -ForegroundColor Green
}

$termuxApi = adb shell pm list packages com.termux.api 2>&1
if ($termuxApi -match "com.termux.api") {
    Write-Host "  OK Termux:API already installed" -ForegroundColor Green
} else {
    Write-Host "  .. Termux:API not found. Downloading..." -ForegroundColor Blue
    $apiUrl = "https://github.com/termux/termux-api/releases/download/v0.50.1/termux-api_v0.50.1+github-debug.apk"
    Invoke-WebRequest -Uri $apiUrl -OutFile "$env:TEMP\termux-api.apk" -UseBasicParsing
    adb install "$env:TEMP\termux-api.apk"
    Write-Host "  OK Termux:API installed" -ForegroundColor Green
}

$shizuku = adb shell pm list packages moe.shizuku.privileged.api 2>&1
if ($shizuku -match "moe.shizuku.privileged.api") {
    Write-Host "  OK Shizuku already installed" -ForegroundColor Green
} else {
    Write-Host "  .. Shizuku not found. Downloading from GitHub..." -ForegroundColor Blue
    $shizukuUrl = "https://github.com/RikkaApps/Shizuku/releases/download/v13.6.0/shizuku-v13.6.0.r1086.2650830c-release.apk"
    Invoke-WebRequest -Uri $shizukuUrl -OutFile "$env:TEMP\shizuku.apk" -UseBasicParsing
    adb install "$env:TEMP\shizuku.apk"
    Write-Host "  OK Shizuku installed" -ForegroundColor Green
}

# -- Step 2: Grant ALL permissions automatically --
Write-Host ""
Write-Host "  [2/7] Granting permissions (no popups needed)..." -ForegroundColor Magenta

$termuxPerms = @(
    "android.permission.READ_EXTERNAL_STORAGE",
    "android.permission.WRITE_EXTERNAL_STORAGE",
    "android.permission.MANAGE_EXTERNAL_STORAGE",
    "android.permission.POST_NOTIFICATIONS"
)
foreach ($p in $termuxPerms) {
    adb shell "pm grant com.termux $p" 2>$null
}

$apiPerms = @(
    "android.permission.CAMERA",
    "android.permission.READ_SMS",
    "android.permission.SEND_SMS",
    "android.permission.RECEIVE_SMS",
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.ACCESS_BACKGROUND_LOCATION",
    "android.permission.READ_CONTACTS",
    "android.permission.WRITE_CONTACTS",
    "android.permission.READ_PHONE_STATE",
    "android.permission.CALL_PHONE",
    "android.permission.RECORD_AUDIO",
    "android.permission.READ_CALL_LOG",
    "android.permission.WRITE_CALL_LOG",
    "android.permission.READ_EXTERNAL_STORAGE",
    "android.permission.WRITE_EXTERNAL_STORAGE",
    "android.permission.POST_NOTIFICATIONS",
    "android.permission.BODY_SENSORS",
    "android.permission.ACTIVITY_RECOGNITION"
)
foreach ($p in $apiPerms) {
    adb shell "pm grant com.termux.api $p" 2>$null
}
Write-Host "  OK All permissions granted silently" -ForegroundColor Green

# -- Step 3: Setup Termux storage symlink --
Write-Host ""
Write-Host "  [3/7] Setting up Termux storage access..." -ForegroundColor Magenta
adb shell "run-as com.termux mkdir -p /data/data/com.termux/files/home/storage" 2>$null
adb shell "run-as com.termux ln -sf /storage/emulated/0 /data/data/com.termux/files/home/storage/shared" 2>$null
Write-Host "  OK Storage linked" -ForegroundColor Green

# -- Step 4: Extract Shizuku rish binaries via ADB --
Write-Host ""
Write-Host "  [4/7] Extracting Shizuku rish binaries..." -ForegroundColor Magenta

$shizukuCheck = adb shell pm path moe.shizuku.privileged.api 2>&1
if ($shizukuCheck -match "package:") {
    $apkPath = ($shizukuCheck -replace "package:", "").Trim()
    adb shell "mkdir -p /sdcard/Shizuku"
    # Pull rish assets from APK on device, then pull to PC, then push to Shizuku folder
    adb shell "cd /sdcard/Shizuku && unzip -o $apkPath assets/rish assets/rish_shizuku.dex" 2>$null
    adb shell "mv /sdcard/Shizuku/assets/rish /sdcard/Shizuku/rish" 2>$null
    adb shell "mv /sdcard/Shizuku/assets/rish_shizuku.dex /sdcard/Shizuku/rish_shizuku.dex" 2>$null
    adb shell "rmdir /sdcard/Shizuku/assets" 2>$null
    Write-Host "  OK Shizuku rish binaries extracted from APK" -ForegroundColor Green
} else {
    Write-Host "  !! Shizuku not found, skipping rish extraction" -ForegroundColor Yellow
}

# -- Step 5: Push all project files --
Write-Host ""
Write-Host "  [5/7] Pushing scripts to phone..." -ForegroundColor Magenta

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

adb push "$projectDir\termux_setup.sh" /sdcard/Download/termux_setup.sh
adb push "$projectDir\scripts\mobile_tools.sh" /sdcard/Download/mobile_tools.sh
adb push "$projectDir\scripts\setup_shizuku.sh" /sdcard/Download/setup_shizuku.sh
Write-Host "  OK All scripts pushed to /sdcard/Download/" -ForegroundColor Green

# -- Step 6: Create bootstrap script --
Write-Host ""
Write-Host "  [6/7] Creating bootstrap script..." -ForegroundColor Magenta

$bootstrapLines = @(
    '#!/data/data/com.termux/files/usr/bin/bash',
    '# Auto-bootstrap for OpenClaude God-Mode',
    'export DEBIAN_FRONTEND=noninteractive',
    '',
    'if [ ! -d ~/storage ]; then',
    '    echo y | termux-setup-storage',
    '    sleep 3',
    'fi',
    '',
    'cp ~/storage/shared/Download/termux_setup.sh ~/termux_setup.sh',
    'mkdir -p ~/scripts',
    'cp ~/storage/shared/Download/mobile_tools.sh ~/scripts/mobile_tools.sh',
    'cp ~/storage/shared/Download/setup_shizuku.sh ~/setup_shizuku.sh',
    'chmod +x ~/scripts/mobile_tools.sh ~/setup_shizuku.sh',
    '',
    'bash ~/setup_shizuku.sh',
    '',
    'grep -q NODE_OPTIONS ~/.bashrc || echo "export NODE_OPTIONS=--dns-result-order=ipv4first" >> ~/.bashrc',
    'export NODE_OPTIONS=--dns-result-order=ipv4first',
    '',
    'echo ""',
    'echo "=========================================="',
    'echo "  Bootstrap complete!"',
    'echo "  Now run: bash ~/termux_setup.sh"',
    'echo "=========================================="',
    'echo ""'
)
$bootstrapContent = $bootstrapLines -join "`n"
[System.IO.File]::WriteAllText("$env:TEMP\bootstrap.sh", $bootstrapContent)
adb push "$env:TEMP\bootstrap.sh" /sdcard/Download/bootstrap.sh
Write-Host "  OK Bootstrap script ready" -ForegroundColor Green

# -- Step 7: Launch Termux --
Write-Host ""
Write-Host "  [7/7] Launching Termux on the phone..." -ForegroundColor Magenta
adb shell "am start -n com.termux/.HomeActivity" 2>$null
Start-Sleep -Seconds 3
Write-Host "  OK Termux launched" -ForegroundColor Green

# -- Done --
Write-Host ""
Write-Host "  ======================================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "  ======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Inside Termux on your phone, run these 2 commands:" -ForegroundColor White
Write-Host ""
Write-Host "  bash ~/storage/shared/Download/bootstrap.sh" -ForegroundColor Yellow
Write-Host "  bash ~/termux_setup.sh" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Done. God-Mode will be live." -ForegroundColor DarkGray
Write-Host ""
