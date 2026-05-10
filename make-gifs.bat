@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM SETTINGS
REM ============================================================
REM Name of the output folder created next to this .bat file.
set "OUTPUT_FOLDER=gifs"

REM Start time inside each video. Examples: 00:00:00, 00:00:05, 00:01:30.
set "START_TIME=00:00:00"

REM GIF duration in seconds.
set "DURATION_SECONDS=5"

REM GIF width in pixels. Height is calculated automatically.
set "GIF_WIDTH=640"

REM Frames per second. Lower value = smaller GIF.
set "FPS=12"

REM Delete the original video after a successful GIF creation?
REM 0 = no, keep the original file. This is the safest default.
REM 1 = yes, delete the original file only if the GIF file was created.
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
        set "OUT=%DEST%\%%~nF.gif"
        echo ----------------------------------------
        echo Creating GIF from: %%~nxF

        ffmpeg -hide_banner -y -ss %START_TIME% -t %DURATION_SECONDS% -i "%%~fF" -vf "fps=%FPS%,scale=%GIF_WIDTH%:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "!OUT!"

        if exist "!OUT!" (
            echo [OK] Created: "!OUT!"
            set /a OK+=1
            if "%DELETE_ORIGINAL%"=="1" del "%%~fF"
        ) else (
            echo [FAILED] Could not create GIF: %%~nxF
            set /a FAILED+=1
        )
    )
)

popd
echo ----------------------------------------
echo Files found: %COUNT%
echo GIFs created: %OK%
echo Failed files: %FAILED%
pause
