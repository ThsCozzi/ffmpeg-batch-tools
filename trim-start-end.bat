@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM SETTINGS
REM ============================================================
REM Name of the output folder created next to this .bat file.
set "OUTPUT_FOLDER=trimmed"

REM Number of seconds to remove from the beginning and end of each video.
set "TRIM_START_SECONDS=0"
set "TRIM_END_SECONDS=0"

REM Video quality / size.
set "CRF=23"
set "PRESET=slow"

REM Delete the original video after a successful trim?
REM 0 = no, keep the original file. This is the safest default.
REM 1 = yes, delete the original file only if the trimmed file was created.
set "DELETE_ORIGINAL=0"

REM Processed extensions. Windows matching is case-insensitive.
set "EXTENSIONS=*.mp4 *.mov *.mkv *.avi *.m4v"

REM ============================================================
REM SCRIPT
REM ============================================================
set "SOURCE=%~dp0"
set "DEST=%SOURCE%%OUTPUT_FOLDER%"

where ffmpeg >nul 2>&1 || (echo [ERROR] ffmpeg not found & pause & exit /b 1)
where ffprobe >nul 2>&1 || (echo [ERROR] ffprobe not found & pause & exit /b 1)
if not exist "%DEST%" mkdir "%DEST%"

pushd "%SOURCE%" || (echo [ERROR] Cannot open source folder & pause & exit /b 1)

set /a COUNT=0
set /a OK=0
set /a FAILED=0

for %%F in (%EXTENSIONS%) do (
    if exist "%%~fF" (
        set /a COUNT+=1
        set "OUT=%DEST%\%%~nF_trimmed.mp4"
        echo ----------------------------------------
        echo Trimming: %%~nxF

        for /f "usebackq delims=" %%D in (`ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%%~fF"`) do set "DURATION=%%D"
        for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "$c=[Globalization.CultureInfo]::InvariantCulture;$d=[double]::Parse('!DURATION!',$c);$s=[double]::Parse('%TRIM_START_SECONDS%',$c);$e=[double]::Parse('%TRIM_END_SECONDS%',$c);$t=$d-$s-$e;if($t -gt 0){$t.ToString('0.###',$c)}else{'INVALID'}"`) do set "TARGET_DURATION=%%T"

        if "!TARGET_DURATION!"=="INVALID" (
            echo [FAILED] Trim settings are longer than the video duration.
            set /a FAILED+=1
        ) else (
            ffmpeg -hide_banner -y -ss %TRIM_START_SECONDS% -i "%%~fF" -t !TARGET_DURATION! -map 0:v:0 -map 0:a? -c:v libx264 -preset %PRESET% -crf %CRF% -c:a aac -b:a 128k -movflags +faststart "!OUT!"

            if exist "!OUT!" (
                echo [OK] Created: "!OUT!"
                set /a OK+=1
                if "%DELETE_ORIGINAL%"=="1" del "%%~fF"
            ) else (
                echo [FAILED] Could not trim: %%~nxF
                set /a FAILED+=1
            )
        )
    )
)

popd
echo ----------------------------------------
echo Files found: %COUNT%
echo Files created: %OK%
echo Failed files: %FAILED%
pause
