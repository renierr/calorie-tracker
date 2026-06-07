param(
  [switch]$Uninstall,
  [switch]$Silent
)

$ErrorActionPreference = 'Stop'
$AppName = 'NutriScan'
$ExeName = 'calorie_tracker.exe'
$Company = 'de.renier'
$InstallDir = Join-Path $env:LOCALAPPDATA $AppName
$StartMenuDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
$ShortcutPath = Join-Path $StartMenuDir "$AppName.lnk"
$ScriptPath = $PSCommandPath
$SourceDir = Join-Path $PSScriptRoot 'dist\NutriScan-windows'
$Version = '0.0.0'

if ($Version -eq '0.0.0' -and (Test-Path (Join-Path $PSScriptRoot 'pubspec.yaml'))) {
  $versionLine = Get-Content (Join-Path $PSScriptRoot 'pubspec.yaml') | Select-String -Pattern '^version:\s*'
  if ($versionLine) {
    $Version = ($versionLine.Line -replace '^version:\s*', '').Trim()
  }
}


function Write-Info  { Write-Host "INFO: $($args[0])" -ForegroundColor Cyan }
function Write-Ok    { Write-Host "OK:   $($args[0])" -ForegroundColor Green }
function Write-Warn  { Write-Host "WARN: $($args[0])" -ForegroundColor Yellow }
function Write-Err   { Write-Host "ERR:  $($args[0])" -ForegroundColor Red }

function Stop-App {
  $proc = Get-Process -Name "$([System.IO.Path]::GetFileNameWithoutExtension($ExeName))" -ErrorAction SilentlyContinue
  if ($proc) {
    Write-Info "Stopping running $AppName..."
    $proc | Stop-Process -Force
    Start-Sleep -Seconds 1
  }
}

function Install-Files {
  Stop-App
  if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
  }
  Write-Info "Copying files to $InstallDir..."
  robocopy $SourceDir $InstallDir /MIR /NJH /NJS /NP /NDL /NC /NS
  if ($LASTEXITCODE -ge 8) {
    Write-Err "robocopy failed with exit code $LASTEXITCODE"
    exit 1
  }
  Write-Ok "Files copied ($((Get-ChildItem $InstallDir -Recurse -File).Count) files)"
}

function Register-UninstallEntry {
  $uninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppName"
  New-Item -Path $uninstallKey -Force | Out-Null
  $exePath = Join-Path $InstallDir $ExeName
  
  # Copy installer script to installation directory so it can be invoked for uninstallation
  $targetScript = Join-Path $InstallDir 'install.ps1'
  Copy-Item -Path $ScriptPath -Destination $targetScript -Force
  
  Set-ItemProperty -Path $uninstallKey -Name 'DisplayName' -Value $AppName
  Set-ItemProperty -Path $uninstallKey -Name 'DisplayVersion' -Value $Version
  Set-ItemProperty -Path $uninstallKey -Name 'DisplayIcon' -Value $exePath
  Set-ItemProperty -Path $uninstallKey -Name 'Publisher' -Value $Company
  Set-ItemProperty -Path $uninstallKey -Name 'InstallLocation' -Value $InstallDir
  
  # Copy to temp, execute silently, and then clean up temp script to avoid locking files
  $uninstallCmd = "powershell -NoProfile -ExecutionPolicy Bypass -Command `"Copy-Item -Path '$targetScript' -Destination '$env:TEMP\uninstall_calorie_tracker.ps1' -Force; & '$env:TEMP\uninstall_calorie_tracker.ps1' -Uninstall -Silent; Remove-Item -Path '$env:TEMP\uninstall_calorie_tracker.ps1' -Force`""
  Set-ItemProperty -Path $uninstallKey -Name 'UninstallString' -Value $uninstallCmd
  
  New-ItemProperty -Path $uninstallKey -Name 'NoModify' -Value 1 -PropertyType DWord -Force | Out-Null
  New-ItemProperty -Path $uninstallKey -Name 'NoRepair' -Value 1 -PropertyType DWord -Force | Out-Null
  $size = [math]::Round((Get-ChildItem $InstallDir -Recurse -File | Measure-Object Length -Sum).Sum / 1KB)
  New-ItemProperty -Path $uninstallKey -Name 'EstimatedSize' -Value $size -PropertyType DWord -Force | Out-Null
  Write-Ok "Registered in Add/Remove Programs"
}

function Install-StartMenuShortcut {
  $exePath = Join-Path $InstallDir $ExeName
  if (-not (Test-Path $StartMenuDir)) {
    New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null
  }
  $shell = New-Object -ComObject WScript.Shell
  $shortcut = $shell.CreateShortcut($ShortcutPath)
  $shortcut.TargetPath = $exePath
  $shortcut.WorkingDirectory = $InstallDir
  $shortcut.Description = $AppName
  $shortcut.Save()
  Write-Ok "Start Menu shortcut created"
}

function Uninstall-All {
  Write-Info "Starting uninstall..."
  # Change working directory to temp to prevent locking the installation directory
  Set-Location $env:TEMP
  # Kill running app
  Stop-App
  # Remove uninstall entry
  $uninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppName"
  if (Test-Path $uninstallKey) {
    Remove-Item -Path $uninstallKey -Recurse -Force
    Write-Ok "Removed uninstall entry"
  }
  # Remove Start Menu shortcut
  if (Test-Path $ShortcutPath) {
    Remove-Item -Path $ShortcutPath -Force
    Write-Ok "Removed Start Menu shortcut"
  }
  # Remove install directory
  if (Test-Path $InstallDir) {
    Remove-Item -Path $InstallDir -Recurse -Force
    Write-Ok "Removed $InstallDir"
  }
  Write-Ok "Uninstall complete"
}

function Install-All {
  if (-not (Test-Path $SourceDir)) {
    Write-Err "Source not found: $SourceDir`nRun 'build.sh windows' first."
    exit 1
  }
  if (-not (Test-Path (Join-Path $SourceDir $ExeName))) {
    Write-Err "$ExeName not found in $SourceDir"
    exit 1
  }
  if (-not $Silent) {
    $answer = Read-Host "Install $AppName to $InstallDir? [Y/n]"
    if ($answer -ne '' -and $answer -notmatch '^[Yy]') {
      Write-Info "Install cancelled"
      exit 0
    }
  }
  Install-Files
  Install-StartMenuShortcut
  Register-UninstallEntry
  Write-Ok "$AppName installed to $InstallDir"
  Write-Info "Run with '-Uninstall' to remove"
}

# --- Entry point ---
Write-Info "Starting installer for $AppName (v$Version)..."
if ($Uninstall) {
  if (-not $Silent) {
    $answer = Read-Host "Uninstall $AppName from $InstallDir? [y/N]"
    if ($answer -match '^[Yy]') {
      Uninstall-All
    } else {
      Write-Info "Uninstall cancelled"
      exit 0
    }
  } else {
    Uninstall-All
  }
} else {
  # Detect existing install
  if (Test-Path $InstallDir) {
    Write-Info "$AppName is already installed at $InstallDir"
    if (-not $Silent) {
      $answer = Read-Host "Reinstall/update? [Y/n]"
      if ($answer -ne '' -and $answer -notmatch '^[Yy]') {
        Write-Info "Update cancelled"
        exit 0
      }
    }
  }
  Install-All
}
