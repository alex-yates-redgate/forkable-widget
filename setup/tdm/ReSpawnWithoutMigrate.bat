echo "If exists, deleting existing dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME]"
rgclone delete dc  Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME] >NUL 2>&1

echo "Creating dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME]"
rgclone create dc -i Widget-[GITHUB_ACCOUNT] -n Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME] -t 8h



echo "Open proxy to dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME]"
rgclone proxy dc Widget-[GITHUB_ACCOUNT]_[BRANCH_NAME]
