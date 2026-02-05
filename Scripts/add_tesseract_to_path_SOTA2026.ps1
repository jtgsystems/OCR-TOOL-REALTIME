#Requires -RunAsAdministrator
<#
.SYNOPSIS
    SOTA 2026 Tesseract OCR PATH Configuration Tool
    
.DESCRIPTION
    Professional-grade PowerShell script for configuring Tesseract OCR
    in the system PATH environment variable with safety checks,
    backup/restore functionality, and comprehensive logging.

.VERSION
    2.0-SOTA2026

.FEATURES
    ✅ Automatic Tesseract detection (multiple locations)
    ✅ PATH backup before modification
    ✅ Duplicate prevention (idempotent)
    ✅ Registry-based permanent PATH update
    ✅ Verification with tesseract --version
    ✅ Colored output for status clarity
    ✅ Error handling and logging

.PARAMETER Restore
    Restore PATH from backup

.PARAMETER Verify
    Verify Tesseract installation without modifying PATH

.EXAMPLE
    .\add_tesseract_to_path_SOTA2026.ps1
    Adds Tesseract to PATH with safety checks

.EXAMPLE
    .\add_tesseract_to_path_SOTA2026.ps1 -Verify
    Only verifies Tesseract installation

.EXAMPLE
    .\add_tesseract_to_path_SOTA2026.ps1 -Restore
    Restores PATH from backup
#>

[CmdletBinding()]
param(
    [switch]$Restore,
    [switch]$Verify
)

# ═════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═════════════════════════════════════════════════════════════════════════════
$Version = "2.0-SOTA2026"
$ScriptName = "Tesseract PATH Configurator"

# Common Tesseract installation paths
$TesseractPaths = @(
    "C:\Program Files\Tesseract-OCR",
    "C:\Program Files (x86)\Tesseract-OCR",
    "${env:LOCALAPPDATA}\Programs\Tesseract-OCR",
    "${env:ProgramFiles}\Tesseract-OCR",
    "${env:ProgramFiles(x86)}\Tesseract-OCR"
)

# Backup file location
$BackupDir = "$env:LOCALAPPDATA\TesseractPathConfig"
$BackupFile = "$BackupDir\PATH_Backup_$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

# ═════════════════════════════════════════════════════════════════════════════
# COLORS
# ═════════════════════════════════════════════════════════════════════════════
$Colors = @{
    Success = 'Green'
    Error = 'Red'
    Warning = 'Yellow'
    Info = 'Cyan'
    Header = 'Magenta'
}

# ═════════════════════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ═════════════════════════════════════════════════════════════════════════════
function Write-Status {
    param(
        [string]$Message,
        [string]$Type = 'Info'
    )
    $color = $Colors[$Type]
    Write-Host "[$Type] $Message" -ForegroundColor $color
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "═" * 60 -ForegroundColor $Colors.Header
    Write-Host "  $Title" -ForegroundColor $Colors.Header
    Write-Host "═" * 60 -ForegroundColor $Colors.Header
    Write-Host ""
}

# ═════════════════════════════════════════════════════════════════════════════
# TESSERACT DETECTION
# ═════════════════════════════════════════════════════════════════════════════
function Find-Tesseract {
    Write-Status "Searching for Tesseract-OCR installation..." 'Info'
    
    foreach ($path in $TesseractPaths) {
        $tesseractExe = Join-Path $path "tesseract.exe"
        if (Test-Path $tesseractExe) {
            Write-Status "Found Tesseract at: $path" 'Success'
            return $path
        }
    }
    
    # Also check if already in PATH
    $existingTesseract = Get-Command tesseract -ErrorAction SilentlyContinue
    if ($existingTesseract) {
        Write-Status "Tesseract already in PATH: $($existingTesseract.Source)" 'Success'
        return $null
    }
    
    return $null
}

# ═════════════════════════════════════════════════════════════════════════════
# PATH MANAGEMENT
# ═════════════════════════════════════════════════════════════════════════════
function Get-SystemPath {
    [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
}

function Set-SystemPath {
    param([string]$NewPath)
    [System.Environment]::SetEnvironmentVariable('Path', $NewPath, [System.EnvironmentVariableTarget]::Machine)
}

function Backup-Path {
    $pathBackup = Get-SystemPath
    
    if (!(Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    $pathBackup | Out-File -FilePath $BackupFile -Encoding UTF8
    Write-Status "PATH backed up to: $BackupFile" 'Success'
    return $BackupFile
}

function Test-PathContains {
    param(
        [string]$CurrentPath,
        [string]$SearchPath
    )
    
    $pathEntries = $CurrentPath -split ';' | ForEach-Object { $_.Trim().TrimEnd('\') }
    $searchNormalized = $SearchPath.Trim().TrimEnd('\')
    
    return $pathEntries -contains $searchNormalized
}

# ═════════════════════════════════════════════════════════════════════════════
# TESSERACT VERIFICATION
# ═════════════════════════════════════════════════════════════════════════════
function Test-TesseractInstall {
    param([string]$TesseractPath)
    
    Write-Status "Verifying Tesseract installation..." 'Info'
    
    $tesseractExe = Join-Path $TesseractPath "tesseract.exe"
    
    if (!(Test-Path $tesseractExe)) {
        Write-Status "tesseract.exe not found at expected location" 'Error'
        return $false
    }
    
    try {
        $output = & $tesseractExe --version 2>&1
        if ($output -match "tesseract") {
            $versionLine = $output | Select-Object -First 1
            Write-Status "Tesseract verified: $versionLine" 'Success'
            return $true
        }
    }
    catch {
        Write-Status "Failed to execute tesseract.exe: $_" 'Error'
        return $false
    }
    
    return $false
}

# ═════════════════════════════════════════════════════════════════════════════
# MAIN FUNCTIONS
# ═════════════════════════════════════════════════════════════════════════════
function Add-TesseractToPath {
    $tesseractPath = Find-Tesseract
    
    if ($null -eq $tesseractPath) {
        Write-Status "Tesseract-OCR not found in standard locations" 'Error'
        Write-Status "Please install Tesseract from: https://github.com/UB-Mannheim/tesseract/wiki" 'Warning'
        return $false
    }
    
    # Verify installation works
    if (!(Test-TesseractInstall -TesseractPath $tesseractPath)) {
        return $false
    }
    
    # Get current PATH
    $currentPath = Get-SystemPath
    
    # Check if already in PATH
    if (Test-PathContains -CurrentPath $currentPath -SearchPath $tesseractPath) {
        Write-Status "Tesseract path already exists in PATH" 'Success'
        return $true
    }
    
    # Backup current PATH
    $backupLocation = Backup-Path
    
    # Add to PATH
    $newPath = $currentPath + ";" + $tesseractPath
    Set-SystemPath -NewPath $newPath
    
    Write-Status "Tesseract added to system PATH" 'Success'
    Write-Status "Path: $tesseractPath" 'Info'
    
    # Refresh environment in current session
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
    
    # Verify
    Write-Status "Verifying PATH update..." 'Info'
    $verification = Get-Command tesseract -ErrorAction SilentlyContinue
    if ($verification) {
        Write-Status "Verification successful! Tesseract is now accessible" 'Success'
        return $true
    }
    else {
        Write-Status "Verification failed. Please restart PowerShell/Terminal" 'Warning'
        return $false
    }
}

function Restore-PathFromBackup {
    Write-Header "RESTORE PATH FROM BACKUP"
    
    if (!(Test-Path $BackupDir)) {
        Write-Status "No backup directory found" 'Error'
        return $false
    }
    
    $backups = Get-ChildItem -Path $BackupDir -Filter "PATH_Backup_*.txt" | Sort-Object LastWriteTime -Descending
    
    if ($backups.Count -eq 0) {
        Write-Status "No backup files found" 'Error'
        return $false
    }
    
    Write-Status "Available backups:" 'Info'
    for ($i = 0; $i -lt [Math]::Min(5, $backups.Count); $i++) {
        Write-Host "  [$i] $($backups[$i].Name) - $($backups[$i].LastWriteTime)"
    }
    
    $selection = Read-Host "Enter number to restore (or 'c' to cancel)"
    
    if ($selection -eq 'c') {
        Write-Status "Restore cancelled" 'Warning'
        return $false
    }
    
    $selectedBackup = $backups[$selection]
    if ($selectedBackup) {
        $oldPath = Get-Content $selectedBackup.FullName -Raw
        Set-SystemPath -NewPath $oldPath
        Write-Status "PATH restored from: $($selectedBackup.Name)" 'Success'
        return $true
    }
    
    return $false
}

# ═════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═════════════════════════════════════════════════════════════════════════════
Write-Header "$ScriptName v$Version"

# Check admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Status "This script requires Administrator privileges" 'Error'
    Write-Status "Please run as Administrator" 'Warning'
    exit 1
}

# Handle parameters
if ($Restore) {
    Restore-PathFromBackup
    exit
}

if ($Verify) {
    Write-Header "VERIFY MODE (No changes will be made)"
    $tesseractPath = Find-Tesseract
    if ($tesseractPath) {
        Test-TesseractInstall -TesseractPath $tesseractPath
    }
    exit
}

# Main operation
Write-Status "Starting Tesseract PATH configuration..." 'Info'
$result = Add-TesseractToPath

if ($result) {
    Write-Header "CONFIGURATION COMPLETE"
    Write-Status "Tesseract-OCR is ready to use!" 'Success'
    Write-Status "You may need to restart open terminals/PowerShell windows" 'Warning'
}
else {
    Write-Header "CONFIGURATION FAILED"
    Write-Status "Please check the error messages above" 'Error'
    exit 1
}
