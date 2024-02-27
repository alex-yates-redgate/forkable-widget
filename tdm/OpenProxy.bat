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
echo Container name: !CONTAINER_NAME!

echo Open proxy to data-container !CONTAINER_NAME!
rgclone proxy data-container !CONTAINER_NAME!

pause

:end
endlocal