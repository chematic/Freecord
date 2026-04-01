$Host.UI.RawUI.WindowTitle = "FREECORD INSTALLATION"
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
    Write-Host "DC OPTIMIZER - 0.2.0 - 2026-06-01"
    Write-Host "$($Ecl.Reset)"
}

Show-Header

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "$($Ecl.Red)[!] ERROR: ADMINISTRATIVE PRIVILEGES REQUIRED.$($Ecl.Reset)"
    exit
}

Write-Host "$($Ecl.Yellow)>> Checking system environment via Winget...$($Ecl.Reset)"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "$($Ecl.Cyan)[i] Node.js missing. Installing...$($Ecl.Reset)"
    winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "$($Ecl.Green)[OK] Node.js detected.$($Ecl.Reset)"
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "$($Ecl.Cyan)[i] Git missing. Installing...$($Ecl.Reset)"
    winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

$targetDir = Join-Path $env:ProgramFiles "Freecord"
$tempRepo = Join-Path $env:TEMP "Freecord_Repo"

if (Test-Path $tempRepo) { Remove-Item $tempRepo -Recurse -Force }

Write-Host "$($Ecl.Yellow)>> Fetching source from GitHub...$($Ecl.Reset)"
git clone --depth 1 https://github.com/chematic/Freecord $tempRepo

Write-Host "$($Ecl.Yellow)>> Deploying to $targetDir...$($Ecl.Reset)"
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Copy-Item -Path "$tempRepo\Freecord\*" -Destination $targetDir -Recurse -Force
Write-Host "$($Ecl.Green)[OK] Files replaced and updated.$($Ecl.Reset)"

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
            }
            Copy-Item -Path $newAsarSource -Destination $resourcePath -Force
            Write-Host "$($Ecl.Green)[OK] Freecord core injected.$($Ecl.Reset)"
        }
    }
}

Remove-Item $tempRepo -Recurse -Force

Write-Host ""
Write-Host "$($Ecl.Magenta)================================================$($Ecl.Reset)"
Write-Host "$($Ecl.Green)$($Ecl.Bold)   INSTALLATION SUCCESSFUL !$($Ecl.Reset)"
Write-Host "$($Ecl.White)   Launch Discord to launch Freecord.$($Ecl.Reset)"
Write-Host "$($Ecl.Magenta)================================================$($Ecl.Reset)"
Pause
