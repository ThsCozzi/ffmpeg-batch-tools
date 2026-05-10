# ffmpeg-batch-tools

Windows batch scripts for bulk video processing with FFmpeg.

This project helps you automate repetitive video tasks on Windows. For example, you can compress an entire folder of vacation videos in one click, speed up long recordings, extract audio from multiple videos, or generate smaller files before archiving or sharing them.

The idea is simple: copy a `.bat` script into a folder containing videos, run it, and let it process every matching file in that folder.

## Features

- Compress videos in bulk with FFmpeg.
- Save processed files into dedicated subfolders.
- Speed up videos and reduce their size.
- Extract audio to MP3.
- Merge videos together in alphabetical order.
- Resize videos to a target resolution.
- Trim the beginning and/or end of videos.
- Remove audio, normalize audio, rename files by date, and create GIFs.
- Choose the output folder name in each script.
- Choose in each script whether original videos should be kept or deleted.

## Requirements

- Windows
- FFmpeg
- FFprobe, included with FFmpeg

## Install FFmpeg On Windows

### Recommended Method With winget

Open PowerShell or CMD, then run:

```bat
winget install Gyan.FFmpeg
```

Close and reopen your terminal, then verify the installation:

```bat
ffmpeg -version
ffprobe -version
```

### Alternative Method With Chocolatey

If Chocolatey is installed:

```bat
choco install ffmpeg
```

Then verify:

```bat
ffmpeg -version
```

### Manual Installation

1. Download FFmpeg from https://www.gyan.dev/ffmpeg/builds/
2. Extract the archive, for example to `C:\ffmpeg`.
3. Add `C:\ffmpeg\bin` to your Windows `PATH`.
4. Reopen CMD or PowerShell.
5. Verify with:

```bat
ffmpeg -version
```

## Included Scripts

| Script | Description | Deletes originals? |
| --- | --- | --- |
| `compress-h265-configurable.bat` | Configurable H.265/HEVC compression, with an optional check that keeps the compressed file only if it is smaller. | No by default |
| `compress-h264.bat` | Simple H.264 compression to the `comp` folder. | No by default |
| `speed-up-videos.bat` | Speeds up videos, scales them down, and writes results to `speed`. | No by default |
| `extract-audio-mp3.bat` | Extracts MP3 audio to the `audio` folder. | No by default |
| `concat-videos-alphabetical.bat` | Merges videos into one file using alphabetical order. | No by default |
| `resize-videos.bat` | Resizes videos to a target height, such as 1080p or 720p. | No by default |
| `trim-start-end.bat` | Removes a chosen number of seconds from the beginning and/or end. | No by default |
| `remove-audio.bat` | Creates muted copies of videos. | No by default |
| `normalize-audio.bat` | Normalizes audio loudness for more consistent volume. | No by default |
| `rename-by-date.bat` | Copies videos with names like `YYYYMMDD-name-001.ext`. | No by default |
| `make-gifs.bat` | Creates short GIFs from videos. | No by default |

## Usage

1. Choose the script you need.
2. Copy the `.bat` file into the folder containing your videos.
3. Double-click the script.
4. Wait for processing to finish.
5. Find the generated files in the subfolder created by the script.

Example:

```text
MyVideos/
  video1.mp4
  video2.mp4
  compress-h265-configurable.bat
```

After running:

```text
MyVideos/
  video1.mp4
  video2.mp4
  comp/
    video1_comp.mp4
    video2_comp.mp4
```

## Script Details

### Common Option: Output Folder

All scripts include this setting near the top of the file:

```bat
set "OUTPUT_FOLDER=comp"
```

It controls the name of the folder where generated files are saved. The folder is created next to the `.bat` file when the script runs.

For example, if you change it to:

```bat
set "OUTPUT_FOLDER=compressed-videos"
```

the script will write its results into a `compressed-videos` subfolder.

Default output folders:

| Script | Default output folder |
| --- | --- |
| `compress-h265-configurable.bat` | `comp` |
| `compress-h264.bat` | `comp` |
| `speed-up-videos.bat` | `speed` |
| `extract-audio-mp3.bat` | `audio` |
| `concat-videos-alphabetical.bat` | `concat` |
| `resize-videos.bat` | `resized` |
| `trim-start-end.bat` | `trimmed` |
| `remove-audio.bat` | `muted` |
| `normalize-audio.bat` | `normalized-audio` |
| `rename-by-date.bat` | `renamed` |
| `make-gifs.bat` | `gifs` |

### Common Option: Keep Or Delete Originals

All scripts include this setting near the top of the file:

```bat
set "DELETE_ORIGINAL=0"
```

It controls whether the original video file should be deleted after a successful operation.

- `0` = keep the original. This is the default and safest setting.
- `1` = delete the original only if the output file was successfully created.

### `compress-h265-configurable.bat`

Recommended script for compressing videos without deleting originals.

By default, it:

- writes files to `comp`
- adds the `_comp` suffix
- uses the `libx265` codec
- uses `CRF=28`
- keeps the compressed file only if it is smaller than the original
- processes `.mp4` and `.mov` files

You can edit the settings at the top of the file:

```bat
set "OUTPUT_FOLDER=comp"
set "CRF=28"
set "PRESET=slow"
set "VIDEO_CODEC=libx265"
set "AUDIO_BITRATE=128k"
set "KEEP_ONLY_IF_SMALLER=1"
set "DELETE_ORIGINAL=0"
```

Quick notes:

- Lower CRF = better quality, larger file.
- Higher CRF = smaller file, lower quality.
- `slow` compresses better than `medium`, but takes more time.
- `libx265` usually compresses better than `libx264`, but may be less compatible with older devices.

### `compress-h264.bat`

Compresses all `.mp4` files from the current folder into the `comp` subfolder.

By default, original videos are kept.

### `speed-up-videos.bat`

Speeds up videos from the current folder and writes the results to `speed`.

By default:

- speed: `x2`
- scale: `80%`
- video codec: H.264
- audio codec: AAC
- FFmpeg logs are written to `speed\logs`

Editable settings at the top of the file:

```bat
set "OUTPUT_FOLDER=speed"
set "SPEED=2.0"
set "SCALE=0.8"
set "CRF=24"
set "PRESET=slow"
set "DELETE_ORIGINAL=0"
```

### `extract-audio-mp3.bat`

Extracts audio from `.mp4` files to MP3 files in the `audio` subfolder.

By default, original videos are kept.

### `concat-videos-alphabetical.bat`

Merges videos from the current folder into a single output file. Files are processed in alphabetical order, so names like `001_intro.mp4`, `002_day1.mp4`, and `003_day2.mp4` will be merged in that order.

By default:

- output folder: `concat`
- output file: `merged-alphabetical.mp4`
- processed extensions: `.mp4`, `.mov`, `.mkv`
- original videos are kept

Editable settings at the top of the file:

```bat
set "OUTPUT_FOLDER=concat"
set "OUTPUT_FILENAME=merged-alphabetical.mp4"
set "DELETE_ORIGINAL=0"
set "OVERWRITE=0"
```

This script uses FFmpeg stream copy mode (`-c copy`), which is fast and does not re-encode the videos. For best results, use videos with the same codec, resolution, frame rate, and audio format.

On Windows, extension matching is case-insensitive. A pattern like `*.mp4` also matches files ending in `.MP4`.

### `resize-videos.bat`

Resizes videos to a target height while keeping the original aspect ratio.

Editable settings at the top of the file:

```bat
set "OUTPUT_FOLDER=resized"
set "TARGET_HEIGHT=1080"
set "CRF=23"
set "PRESET=slow"
set "DELETE_ORIGINAL=0"
```

Examples for `TARGET_HEIGHT`: `2160`, `1440`, `1080`, `720`, `480`.

### `trim-start-end.bat`

Trims a fixed number of seconds from the beginning and/or end of each video.

Editable settings at the top of the file:

```bat
set "OUTPUT_FOLDER=trimmed"
set "TRIM_START_SECONDS=0"
set "TRIM_END_SECONDS=0"
set "CRF=23"
set "PRESET=slow"
set "DELETE_ORIGINAL=0"
```

For example, set `TRIM_START_SECONDS=5` to remove the first 5 seconds from every video.

### `remove-audio.bat`

Creates muted copies of videos by removing the audio track.

Editable settings at the top of the file:

```bat
set "OUTPUT_FOLDER=muted"
set "DELETE_ORIGINAL=0"
```

This script uses stream copy for the video track, so it is fast and does not re-encode video.

### `normalize-audio.bat`

Normalizes audio loudness so videos have a more consistent volume.

Editable settings at the top of the file:

```bat
set "OUTPUT_FOLDER=normalized-audio"
set "AUDIO_FILTER=loudnorm=I=-16:LRA=11:TP=-1.5"
set "CRF=23"
set "PRESET=slow"
set "DELETE_ORIGINAL=0"
```

Videos without an audio track will fail because there is no audio to normalize.

### `rename-by-date.bat`

Copies videos into a new folder with a date-based name.

Output format:

```text
YYYYMMDD-CUSTOM_NAME-ID.ext
```

Example:

```text
20260510-vacation-001.mp4
20260510-vacation-002.mp4
```

Editable settings at the top of the file:

```bat
set "OUTPUT_FOLDER=renamed"
set "CUSTOM_NAME=video"
set "START_ID=1"
set "ID_DIGITS=3"
set "DELETE_ORIGINAL=0"
```

By default, the script uses each file creation date and copies files into the `renamed` folder. If `DELETE_ORIGINAL=1`, originals are deleted after the renamed copy is created.

### `make-gifs.bat`

Creates a short GIF from each video.

Editable settings at the top of the file:

```bat
set "OUTPUT_FOLDER=gifs"
set "START_TIME=00:00:00"
set "DURATION_SECONDS=5"
set "GIF_WIDTH=640"
set "FPS=12"
set "DELETE_ORIGINAL=0"
```

Lower `GIF_WIDTH`, `FPS`, or `DURATION_SECONDS` values produce smaller GIF files.

## Safety Notes

Before setting `DELETE_ORIGINAL` to `1`:

- test the script on a copy of a few videos
- verify that the output matches what you expect
- keep a backup if the files are important

## License

To be defined.
