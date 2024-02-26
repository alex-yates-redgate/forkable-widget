@echo off
setlocal

REM Set relative paths for source and target directories
set "sourceDirectory=.\tdm"
set "targetDirectory=.\spawn"

REM Get the GitHub account from the GitHub URL
for /f "tokens=3 delims=/" %%A in ('git config --get remote.origin.url') do (
    set "GITHUB_URL=%%A"
)
for /f "tokens=1 delims=/" %%B in ("%GITHUB_URL%") do (
    set "GITHUB_ACCOUNT=%%B"
)

REM Get the current Git branch name
for /f "tokens=*" %%C in ('git rev-parse --abbrev-ref HEAD') do (
    set "BRANCH_NAME=%%C"
)

REM Replace non-alphanumeric characters in the branch name with "-"
echo "1 - %BRANCH_NAME%"

REM Check if the target directory exists and delete it if it does
if exist "%targetDirectory%" (
    rmdir /s /q "%targetDirectory%"
)

REM Create the new directory
mkdir "%targetDirectory%"

REM Copy all files from the source directory to the new directory
xcopy "%sourceDirectory%\*" "%targetDirectory%\" /s /e

echo Files copied successfully.

REM Replace [GITHUB_ACCOUNT] in files with the actual GitHub account
for %%i in ("%targetDirectory%\*") do (
    set "file=%%i"
    setlocal enabledelayedexpansion
    for /f "delims=" %%j in ('type "!file!"') do (
        set "line=%%j"
        set "line=!line:[GITHUB_ACCOUNT]=%GITHUB_ACCOUNT%!"
        set "line=!line:[BRANCH_NAME]=%BRANCH_NAME%!"
        echo !line!>> "!file!.tmp"
    )
    move /y "!file!.tmp" "!file!" >nul
    endlocal
)

REM Create .gitignore file to ignore the entire directory
echo * > "%targetDirectory%\.gitignore"

pause

endlocal
