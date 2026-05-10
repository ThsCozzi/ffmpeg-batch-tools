@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM SETTINGS
REM ============================================================
REM Name of the output folder created next to this .bat file.
set "OUTPUT_FOLDER=concat"

REM Name of the merged video file.
set "OUTPUT_FILENAME=merged-alphabetical.mp4"

REM Delete original videos after a successful merge?
REM 0 = no, keep the original files. This is the safest default.
REM 1 = yes, delete the original files only if the merged file was created.
set "DELETE_ORIGINAL=0"

REM Overwrite the merged output file if it already exists?
REM 0 = no, stop before overwriting.
REM 1 = yes, replace the existing output file.
set "OVERWRITE=0"

REM Processed extensions. Files are merged in alphabetical order.
REM Windows matching is case-insensitive.
set "EXTENSIONS=*.mp4 *.mov *.mkv"

REM ============================================================
REM SCRIPT
REM ============================================================
set "SOURCE=%~dp0"
set "DEST=%SOURCE%%OUTPUT_FOLDER%"
set "OUTPUT=%DEST%\%OUTPUT_FILENAME%"
set "LIST_FILE=%DEST%\ffmpeg-concat-list.txt"

where ffmpeg >nul 2>&1 || (echo [ERROR] ffmpeg not found & pause & exit /b 1)
if not exist "%DEST%" mkdir "%DEST%"

if exist "%OUTPUT%" (
    if "%OVERWRITE%"=="0" (
        echo [ERROR] Output file already exists: "%OUTPUT%"
        echo Set OVERWRITE=1 to replace it.
        pause
        exit /b 1
    )
)

if exist "%LIST_FILE%" del "%LIST_FILE%"

pushd "%SOURCE%" || (echo [ERROR] Cannot open source folder & pause & exit /b 1)

set /a COUNT=0
for /f "delims=" %%F in ('dir /b /a-d /on %EXTENSIONS% 2^>nul') do (
    echo file '%SOURCE%%%F'>> "%LIST_FILE%"
    echo Added: %%F
    set /a COUNT+=1
)

popd

if %COUNT% LSS 2 (
    echo [ERROR] At least 2 videos are required to merge.
    if exist "%LIST_FILE%" del "%LIST_FILE%"
    pause
    exit /b 1
)

ffmpeg -hide_banner -y -f concat -safe 0 -i "%LIST_FILE%" -c copy "%OUTPUT%"

if exist "%LIST_FILE%" del "%LIST_FILE%"

if exist "%OUTPUT%" (
    echo [OK] Merged video created: "%OUTPUT%"
    if "%DELETE_ORIGINAL%"=="1" (
        pushd "%SOURCE%"
        for /f "delims=" %%F in ('dir /b /a-d /on %EXTENSIONS% 2^>nul') do del "%%F"
        popd
    )
) else (
    echo [FAILED] Could not merge videos.
)

pause
