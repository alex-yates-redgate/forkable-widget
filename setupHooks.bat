@echo off
echo Copying hooks to .git/hooks
xcopy "hooks\*" ".git\hooks\" /E /I /Y
echo Done
pause