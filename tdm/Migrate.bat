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

echo Capturing JDBC connection string
for /f "tokens=1,* delims=:" %%A in ('rgclone get dc !CONTAINER_NAME! -o yaml 2^>NUL ^| findstr /c:"jdbcconnectionstring:"') do (
    set "jdbc_connection_string=%%B"
)
set "dbJdbc=!jdbc_connection_string!databaseName=WidgetProduction"
rem Remove leading and trailing spaces
set "dbJdbc=%dbJdbc: =%"
echo   JDBC is: %dbJdbc%

echo Running: flyway migrate -url="%dbJdbc%" -locations="filesystem:../migrations"
flyway migrate -url="%dbJdbc%" -locations="filesystem:../migrations"

echo Open proxy to data-container !CONTAINER_NAME!
rgclone proxy data-container !CONTAINER_NAME!

pause

:end
endlocal

