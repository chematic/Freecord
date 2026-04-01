$Host.UI.RawUI.WindowTitle = "FREECORD ELITE - FINAL SETUP"
$Ecl = @{
    Cyan    = "$([char]27)[36m"
    Green   = "$([char]27)[32m"
    Red     = "$([char]27)[31m"
    Yellow  = "$([char]27)[33m"
    White   = "$([char]27)[37m"
    Magenta = "$([char]27)[35m"
    Reset   = "$([char]27)[0m"
    Bold    = "$([char]27)[1m"
}

function Show-Header {
    Clear-Host
    Write-Host "$($Ecl.Magenta)$($Ecl.Bold)"
    Write-Host "  ███████╗██████╗ ███████╗███████╗ ██████╗ ██████╗ ██████╗ ██████╗ "
    Write-Host "  ██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔══██╗"
    Write-Host "  █████╗  ██████╔╝█████╗  █████╗  ██║     ██║   ██║██████╔╝██║  ██║"
    Write-Host "  ██╔══╝  ██╔══██╗██╔══╝  ██╔══╝  ██║     ██║   ██║██╔══██╗██║  ██║"
    Write-Host "  ██║     ██║  ██║███████╗███████╗╚██████╗╚██████╔╝██║  ██║██████╔╝"
    Write-Host "  ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ "
    Write-Host "                                         KERNEL-LEVEL OPTIMIZER v1.0"
    Write-Host "$($Ecl.Reset)"
}

Show-Header

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "$($Ecl.Red)[!] ERROR: ADMINISTRATIVE PRIVILEGES REQUIRED.$($Ecl.Reset)"
    exit
}

Write-Host "$($Ecl.Yellow)>> Checking system environment...$($Ecl.Reset)"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "$($Ecl.Cyan)[i] Node.js missing. Installing via Winget...$($Ecl.Reset)"
    winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "$($Ecl.Green)[OK] Node.js detected.$($Ecl.Reset)"
}

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Host "$($Ecl.Red)[!] Fatal: NPX not found.$($Ecl.Reset)"
    exit
}
Write-Host "$($Ecl.Green)[OK] Runtime environment ready.$($Ecl.Reset)"

$targetDir = Join-Path $env:ProgramFiles "Freecord"
$sourceDir = $PSScriptRoot

Write-Host "$($Ecl.Yellow)>> Deploying to $targetDir...$($Ecl.Reset)"

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Copy-Item -Path "$sourceDir\Freecord\*" -Destination $targetDir -Recurse -Force
Write-Host "$($Ecl.Green)[OK] System files installed.$($Ecl.Reset)"

Write-Host "$($Ecl.Yellow)>> Initializing injection protocol...$($Ecl.Reset)"

$discordProc = Get-Process Discord -ErrorAction SilentlyContinue
if ($discordProc) {
    Write-Host "$($Ecl.Cyan)[i] Force closing Discord...$($Ecl.Reset)"
    Stop-Process -Name Discord -Force
    Start-Sleep -Seconds 2
}

$discordBase = Join-Path $env:LOCALAPPDATA "Discord"

if (Test-Path $discordBase) {
    $versionDir = Get-ChildItem -Path $discordBase -Filter "app-*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($versionDir) {
        $resourcePath = Join-Path $versionDir.FullName "resources"
        $originalAsar = Join-Path $resourcePath "app.asar"
        $backupAsar = Join-Path $resourcePath "freecord.asar"
        $newAsarSource = Join-Path $targetDir "App\app.asar"

        if (Test-Path $originalAsar) {
            if (-not (Test-Path $backupAsar)) {
                Rename-Item -Path $originalAsar -NewName "freecord.asar" -Force
                Write-Host "$($Ecl.Green)[OK] Original asar renamed to freecord.asar.$($Ecl.Reset)"
            } else {
                Remove-Item $originalAsar -Force
                Write-Host "$($Ecl.Cyan)[i] Replacing existing asar.$($Ecl.Reset)"
            }

            Copy-Item -Path $newAsarSource -Destination $resourcePath -Force
            Write-Host "$($Ecl.Green)[OK] Freecord core injected.$($Ecl.Reset)"
        }
    } else {
        Write-Host "$($Ecl.Red)[!] app-* directory not found.$($Ecl.Reset)"
    }
} else {
    Write-Host "$($Ecl.Red)[!] Discord installation not found.$($Ecl.Reset)"
}

Write-Host ""
Write-Host "$($Ecl.Magenta)================================================$($Ecl.Reset)"
Write-Host "$($Ecl.Green)$($Ecl.Bold)   INSTALLATION SUCCESSFUL$($Ecl.Reset)"
Write-Host "$($Ecl.White)   Launch Discord to activate optimization.$($Ecl.Reset)"
Write-Host "$($Ecl.Magenta)================================================$($Ecl.Reset)"
Pause