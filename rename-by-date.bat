@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM SETTINGS
REM ============================================================
REM Name of the output folder created next to this .bat file.
set "OUTPUT_FOLDER=renamed"

REM Output format: YYYYMMDD-CUSTOM_NAME-ID.ext
set "CUSTOM_NAME=video"

REM First numeric id.
set "START_ID=1"

REM Number of digits used for the id. Example: 3 gives 001, 002, 003.
set "ID_DIGITS=3"

REM Delete the original file after a successful renamed copy?
REM 0 = no, keep the original file. This is the safest default.
REM 1 = yes, delete the original file only if the renamed copy was created.
set "DELETE_ORIGINAL=0"

REM Processed extensions. Windows matching is case-insensitive.
set "EXTENSIONS=*.mp4 *.mov *.mkv *.avi *.m4v"

REM ============================================================
REM SCRIPT
REM ============================================================
set "SOURCE=%~dp0"
set "DEST=%SOURCE%%OUTPUT_FOLDER%"
set /a CURRENT_ID=%START_ID%

if not exist "%DEST%" mkdir "%DEST%"

pushd "%SOURCE%" || (echo [ERROR] Cannot open source folder & pause & exit /b 1)

set /a COUNT=0
set /a OK=0
set /a SKIPPED=0

for /f "delims=" %%F in ('dir /b /a-d /od %EXTENSIONS% 2^>nul') do (
    set /a COUNT+=1
    for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "(Get-Item -LiteralPath '%%~fF').CreationTime.ToString('yyyyMMdd')"`) do set "FILE_DATE=%%D"
    for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "('{0:D%ID_DIGITS%}' -f !CURRENT_ID!)"`) do set "PADDED_ID=%%I"

    set "OUT=%DEST%\!FILE_DATE!-%CUSTOM_NAME%-!PADDED_ID!%%~xF"
    echo ----------------------------------------
    echo Copying: %%F
    echo To     : !OUT!

    if exist "!OUT!" (
        echo [SKIPPED] Output already exists.
        set /a SKIPPED+=1
    ) else (
        copy /y "%%~fF" "!OUT!" >nul
        if exist "!OUT!" (
            echo [OK] Created: "!OUT!"
            set /a OK+=1
            if "%DELETE_ORIGINAL%"=="1" del "%%~fF"
        ) else (
            echo [FAILED] Could not copy.
            set /a SKIPPED+=1
        )
    )

    set /a CURRENT_ID+=1
)

popd
echo ----------------------------------------
echo Files found: %COUNT%
echo Files copied: %OK%
echo Skipped files: %SKIPPED%
pause
