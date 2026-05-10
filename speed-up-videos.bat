@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM SETTINGS
REM ============================================================
REM Name of the output folder created next to this .bat file.
set "OUTPUT_FOLDER=speed"

REM Speed multiplier.
set "SPEED=2.0"

REM Scale factor: 1 = original, 0.8 = 80%, 0.6 = 60%, etc.
set "SCALE=0.8"

REM Video quality / size.
set "CRF=24"
set "PRESET=slow"

REM Delete the original video after a successful speed-up?
REM 0 = no, keep the original file. This is the safest default.
REM 1 = yes, delete the original file only if the output file was created.
set "DELETE_ORIGINAL=0"

REM Processed extensions. Windows matching is case-insensitive.
set "EXTENSIONS=*.mp4 *.mov *.mkv *.avi *.m4v"

REM ============================================================
REM SCRIPT
REM ============================================================
set "SOURCE=%~dp0"
set "DEST=%SOURCE%%OUTPUT_FOLDER%"
set "LOGDIR=%DEST%\logs"

where ffmpeg >nul 2>&1 || (echo [ERROR] ffmpeg not found & pause & exit /b 1)
where ffprobe >nul 2>&1 || (echo [ERROR] ffprobe not found & pause & exit /b 1)
if not exist "%DEST%" mkdir "%DEST%"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

pushd "%SOURCE%" || (echo [ERROR] Cannot open source folder & pause & exit /b 1)

set /a COUNT=0
set /a OK=0
set /a FAILED=0

for %%F in (%EXTENSIONS%) do (
    if exist "%%~fF" (
        set /a COUNT+=1
        set "OUT=%DEST%\%%~nF_x%SPEED%.mp4"
        set "LOG=%LOGDIR%\%%~nF_ffmpeg.log"
        set "HAS_AUDIO=0"

        for /f %%A in ('ffprobe -v error -select_streams a -show_entries stream^=codec_type -of csv^=p^=0 "%%~fF"') do set "HAS_AUDIO=1"

        set "VFILTER=setpts=PTS/%SPEED%,scale=trunc(iw*%SCALE%/2)*2:trunc(ih*%SCALE%/2)*2"

        echo ----------------------------------------
        echo Speeding up: %%~nxF

        if "!HAS_AUDIO!"=="1" (
            ffmpeg -hide_banner -y -i "%%~fF" -filter_complex "[0:v]!VFILTER![v];[0:a]atempo=%SPEED%[a]" -map "[v]" -map "[a]" -c:v libx264 -preset %PRESET% -crf %CRF% -c:a aac -b:a 192k "!OUT!" > "!LOG!" 2>&1
        ) else (
            ffmpeg -hide_banner -y -i "%%~fF" -filter:v "!VFILTER!" -an -c:v libx264 -preset %PRESET% -crf %CRF% "!OUT!" > "!LOG!" 2>&1
        )

        if exist "!OUT!" (
            echo [OK] Created: "!OUT!"
            set /a OK+=1
            if "%DELETE_ORIGINAL%"=="1" del "%%~fF"
        ) else (
            echo [FAILED] Could not speed up: %%~nxF. See log: "!LOG!"
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
