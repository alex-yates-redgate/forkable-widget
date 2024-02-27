@echo off
setlocal enabledelayedexpansion

rem Querying git to work out names of daa-images and data-containers
for /f "tokens=*" %%a in ('git remote get-url origin') do (
    set "URL=%%a"
)
for /f "tokens=3 delims=/" %%b in ("!URL!") do (
    set "GITHUB_ACCOUNT=%%b"
)
for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD') do set CURRENT_BRANCH=%%i
set IMAGE_NAME=Widget-!GITHUB_ACCOUNT!
set CONTAINER_NAME=!IMAGE_NAME!_!CURRENT_BRANCH!

rem Logging vars for debugging
echo GitHub URL:     !URL!
echo GitHub account: !GITHUB_ACCOUNT!
echo Current branch: !CURRENT_BRANCH!
echo Image name:     !IMAGE_NAME!
echo Container name: !CONTAINER_NAME!

rem Searching for a container with the appropriate name

set "pattern=name: !CONTAINER_NAME!"
set "found=false"

for /f "tokens=* delims=" %%a in ('rgclone get dc -o yaml') do (
    echo %%a | findstr /C:"%pattern%" > nul
    if not errorlevel 1 (
        set "found=true"
        goto :break
    )
)

:break

if "%found%"=="true" (
    echo Container !CONTAINER_NAME! already exists
) else (
    echo Container !CONTAINER_NAME! does not already exist. Creating now.
    rgclone create data-container --image !IMAGE_NAME! --name !CONTAINER_NAME! --lifetime 8h
)

pause

:end
endlocal

