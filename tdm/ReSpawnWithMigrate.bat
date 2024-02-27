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

rem Rather than using rgclone delete, we use rgclone update to set a lifetime of 1m, because it's faster.
rem We also rename the old data-container to include a random number to avoid name clashes.
echo If exists, deleting existing data-container !CONTAINER_NAME!
set /a "rand=(%random% %% 10000) + 1"
rgclone update data-container !CONTAINER_NAME! --lifetime 1m --name !CONTAINER_NAME!_old_!rand! >NUL 2>&1

rem ReSpawning the data-container
echo Creating data-container !CONTAINER_NAME!
rgclone create data-container --image !IMAGE_NAME! --name !CONTAINER_NAME! --lifetime 8h

echo Capturing JDBC connection string
for /f "tokens=1,* delims=:" %%A in ('rgclone get dc !CONTAINER_NAME! -o yaml 2^>NUL ^| findstr /c:"jdbcconnectionstring:"') do (
    set "jdbc_connection_string=%%B"
)
set "dbJdbc=!jdbc_connection_string!databaseName=WidgetProduction"
rem Remove leading and trailing spaces
set "dbJdbc=%dbJdbc: =%"
echo   JDBC is: %dbJdbc%

for /f "tokens=* delims=" %%a in ('git rev-parse --show-toplevel') do set "repo_path=%%a"
echo Repository Root: %repo_path%

echo Running: flyway migrate -url="%dbJdbc%" -locations="filesystem:../migrations"
flyway migrate -url="%dbJdbc%" -locations="filesystem:%repo_path%/migrations"

echo Open proxy to data-container !CONTAINER_NAME!
rgclone proxy data-container !CONTAINER_NAME!

pause

:end
endlocal

