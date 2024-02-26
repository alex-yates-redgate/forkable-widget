@echo off
setlocal enabledelayedexpansion
echo If exists, deleting existing dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME]
rgclone delete dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME] >NUL 2>&1

echo Creating dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME]
rgclone create dc -i Widget-[GITHUB_ACCOUNT] -n Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME] -t 8h

echo Capturing JDBC connection string
for /f "tokens=1,* delims=:" %%A in ('rgclone get dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME] -o yaml 2^>NUL ^| findstr /c:"jdbcconnectionstring:"') do (
    set "jdbc_connection_string=%%B"
)
set "dbJdbc=!jdbc_connection_string!databaseName=WidgetProduction"
echo   JDBC is: %dbJdbc%

pause

echo Running: flyway migrate -url="%dbJdbc%" -locations="filesystem:../../migrations"
flyway migrate -url="%dbJdbc%" -locations="filesystem:../../migrations"

pause

echo Open proxy to dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME]
rgclone proxy dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME]

:end
endlocal
