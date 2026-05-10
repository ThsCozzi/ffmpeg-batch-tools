@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM SETTINGS
REM ============================================================
REM Name of the output folder created next to this .bat file.
set "OUTPUT_FOLDER=audio"

REM Delete the original video after a successful audio extraction?
REM 0 = no, keep the original file. This is the safest default.
REM 1 = yes, delete the original file only if the MP3 file was created.
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
        set "OUT=%DEST%\%%~nF.mp3"
        echo ----------------------------------------
        echo Extracting audio from: %%~nxF

        ffmpeg -hide_banner -y -i "%%~fF" -vn -c:a libmp3lame -q:a 2 "!OUT!"

        if exist "!OUT!" (
            echo [OK] Created: "!OUT!"
            set /a OK+=1
            if "%DELETE_ORIGINAL%"=="1" del "%%~fF"
        ) else (
            echo [FAILED] Could not extract audio: %%~nxF
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
