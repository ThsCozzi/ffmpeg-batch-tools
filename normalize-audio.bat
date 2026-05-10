@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM SETTINGS
REM ============================================================
REM Name of the output folder created next to this .bat file.
set "OUTPUT_FOLDER=normalized-audio"

REM Audio normalization filter.
set "AUDIO_FILTER=loudnorm=I=-16:LRA=11:TP=-1.5"

REM Video quality / size.
set "CRF=23"
set "PRESET=slow"

REM Delete the original video after a successful normalization?
REM 0 = no, keep the original file. This is the safest default.
REM 1 = yes, delete the original file only if the normalized file was created.
set "DELETE_ORIGINAL=0"

REM Processed extensions. Windows matching is case-insensitive.
set "EXTENSIONS=*.mp4 *.mov *.mkv *.avi *.m4v"

REM ============================================================
REM SCRIPT
REM ============================================================
set "SOURCE=%~dp0"
set "DEST=%SOURCE%%OUTPUT_FOLDER%"

where ffmpeg >nul 2>&1 || (echo [ERROR] ffmpeg not found & pause & exit /b 1)
if not exist "%DEST%" mkdir "%DEST%"

pushd "%SOURCE%" || (echo [ERROR] Cannot open source folder & pause & exit /b 1)

set /a COUNT=0
set /a OK=0
set /a FAILED=0

for %%F in (%EXTENSIONS%) do (
    if exist "%%~fF" (
        set /a COUNT+=1
        set "OUT=%DEST%\%%~nF_normalized.mp4"
        echo ----------------------------------------
        echo Normalizing audio: %%~nxF

        ffmpeg -hide_banner -y -i "%%~fF" -map 0:v:0 -map 0:a:0 -c:v libx264 -preset %PRESET% -crf %CRF% -af "%AUDIO_FILTER%" -c:a aac -b:a 192k -movflags +faststart "!OUT!"

        if exist "!OUT!" (
            echo [OK] Created: "!OUT!"
            set /a OK+=1
            if "%DELETE_ORIGINAL%"=="1" del "%%~fF"
        ) else (
            echo [FAILED] Could not normalize audio: %%~nxF
            set /a FAILED+=1
        )
    )
)

popd
echo ----------------------------------------
echo Files found: %COUNT%
echo Files created: %OK%
echo Failed files: %FAILED%
pause
