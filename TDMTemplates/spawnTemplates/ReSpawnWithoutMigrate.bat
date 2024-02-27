@echo off

echo If exists, deleting existing dc Widget-GitHub_ACCOUNT_BRANCH_NAME
rgclone delete dc  Widget-GitHub_ACCOUNT_BRANCH_NAME >NUL 2>&1

echo Creating dc Widget-GitHub_ACCOUNT_BRANCH_NAME
rgclone create dc -i Widget-GitHub_ACCOUNT -n Widget-GitHub_ACCOUNT_BRANCH_NAME -t 8h

echo Open proxy to dc Widget-GitHub_ACCOUNT_BRANCH_NAME
rgclone proxy dc Widget-GitHub_ACCOUNT_BRANCH_NAME
