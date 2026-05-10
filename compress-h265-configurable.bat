@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM SETTINGS
REM ============================================================
REM Name of the output folder created next to this .bat file.
set "OUTPUT_FOLDER=comp"

REM Suffix added to the compressed file name.
set "OUTPUT_SUFFIX=_comp"

REM Video quality. Lower CRF = better quality and larger file.
set "CRF=28"

REM Preset: medium, slow, slower.
set "PRESET=slow"

REM Video codec: libx264 or libx265.
set "VIDEO_CODEC=libx265"

REM Audio bitrate.
set "AUDIO_BITRATE=128k"

REM Overwrite existing output files?
REM 0 = no
REM 1 = yes
set "OVERWRITE=0"

REM Keep the compressed file only if it is smaller than the original?
REM 1 = yes, recommended
REM 0 = no, always keep
set "KEEP_ONLY_IF_SMALLER=1"

REM Delete the original video after a successful compression?
REM 0 = no, keep the original file. This is the safest default.
REM 1 = yes, delete the original file only if the compressed file was kept.
set "DELETE_ORIGINAL=0"

REM Processed extensions. Windows matching is case-insensitive.
set "EXTENSIONS=*.mp4 *.mov"

REM ============================================================
REM SCRIPT
REM ============================================================
set "SOURCE=%~dp0"
set "DEST=%SOURCE%%OUTPUT_FOLDER%"

where ffmpeg >nul 2>&1 || (echo [ERROR] ffmpeg not found & pause & exit /b 1)
if not exist "%DEST%" mkdir "%DEST%"

pushd "%SOURCE%" || (echo [ERROR] Cannot open source folder & pause & exit /b 1)

set /a COUNT=0
set /a KEPT=0
set /a SKIPPED=0
set /a BIGGER=0
set /a FAILED=0

for %%F in (%EXTENSIONS%) do (
    if exist "%%~fF" (
        set /a COUNT+=1
        set "OUT=%DEST%\%%~nF%OUTPUT_SUFFIX%.mp4"
        set "TEMP=%DEST%\%%~nF%OUTPUT_SUFFIX%_temp.mp4"

        echo ----------------------------------------
        echo Compressing: %%~nxF

        if exist "!OUT!" (
            if "%OVERWRITE%"=="0" (
                echo [SKIPPED] Output already exists.
                set /a SKIPPED+=1
            ) else (
                del "!OUT!"
            )
        )

        if not exist "!OUT!" (
            if exist "!TEMP!" del "!TEMP!"

            ffmpeg -hide_banner -y -i "%%~fF" -map 0:v:0 -map 0:a? -c:v %VIDEO_CODEC% -preset %PRESET% -crf %CRF% -pix_fmt yuv420p -tag:v hvc1 -c:a aac -b:a %AUDIO_BITRATE% -movflags +faststart "!TEMP!"

            if exist "!TEMP!" (
                for %%A in ("%%~fF") do set "ORIGINAL_SIZE=%%~zA"
                for %%B in ("!TEMP!") do set "COMPRESSED_SIZE=%%~zB"

                if "%KEEP_ONLY_IF_SMALLER%"=="1" (
                    if !COMPRESSED_SIZE! GEQ !ORIGINAL_SIZE! (
                        echo [SKIPPED] Compressed file is larger or identical.
                        del "!TEMP!"
                        set /a BIGGER+=1
                    ) else (
                        ren "!TEMP!" "%%~nF%OUTPUT_SUFFIX%.mp4"
                    )
                ) else (
                    ren "!TEMP!" "%%~nF%OUTPUT_SUFFIX%.mp4"
                )

                if exist "!OUT!" (
                    echo [OK] Created: "!OUT!"
                    set /a KEPT+=1
                    if "%DELETE_ORIGINAL%"=="1" del "%%~fF"
                )
            ) else (
                echo [FAILED] Could not compress: %%~nxF
                set /a FAILED+=1
            )
        )
    )
)

popd
echo ----------------------------------------
echo Files found: %COUNT%
echo Files kept: %KEPT%
echo Existing skipped: %SKIPPED%
echo Larger skipped: %BIGGER%
echo Failed files: %FAILED%
pause
