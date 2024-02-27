function Copy-Files {
    param(
        [string]$sourceDir,
        [string]$targetDir
    )

    if (Test-Path $targetDir) {
        Remove-Item -Path $targetDir -Recurse -Force
    }

    New-Item $targetDir -ItemType Directory | Out-Null

    $files = Get-ChildItem -Path $sourceDir -File
    foreach ($file in $files) {
        $sourceFile = Join-Path -Path $sourceDir -ChildPath $file.Name
        $targetFile = Join-Path -Path $targetDir -ChildPath $file.Name
        Copy-Item -Path $sourceFile -Destination $targetFile -Force | Out-Null
    }
}

function Update-Placeholders {
    param(
        $targetDir,
        [string]$oldText,
        [string]$newText
    )
    $files = Get-ChildItem -Path $targetDir -File
    foreach ($file in $files){
        $oldContent = Get-Content $file.FullName -Raw
        $newContent = $oldContent -replace $oldText, $newText
        Set-Content -Path $file.FullName -Value $newContent
    }
}


# Sorting oput all my file paths
$gitRoot = $PSScriptRoot
Write-Output "Git root: $gitRoot"
$templatesDir = Join-Path -Path $gitRoot -ChildPath "TDMTemplates"
$hookTemplatesDir = Join-Path -Path $templatesDir -ChildPath "hookTemplates"
$hookTempDir = Join-Path -Path $templatesDir -ChildPath "hooksTemp"
$hookTargetDir = Join-Path -Path (Join-Path -Path $gitRoot -ChildPath ".git") -ChildPath "hooks"
$spawnTemplatesDir = Join-Path -Path $templatesDir -ChildPath "spawnTemplates"
$spawnTempDir = Join-Path -Path $templatesDir -ChildPath "spawnTemp"
$spawnTargetDir = Join-Path -Path $gitRoot -ChildPath "spawn"

Write-Output "Hook templates directory: $hookTemplatesDir"
Write-Output "Hook temp directory: $hookTempDir" 
Write-Output "Hook target directory: $hookTargetDir"
Write-Output "Spawn templates directory: $spawnTemplatesDir"
Write-Output "Spawn temp directory: $spawnTempDir"
Write-Output "Spawn target directory: $spawnTargetDir"
Write-Output ""

# Get the GitHub account and branch name
$remoteUrl = git remote get-url origin
$githubAccount = $remoteUrl -replace '^https:\/\/github\.com\/([^\/]+)\/.*$', '$1'
$currentBranch = git rev-parse --abbrev-ref HEAD

Write-Output "GitHub account is: $githubAccount"
Write-Output "Current branch is: $currentBranch"
Write-Output ""

Write-Output "Copying hook templates to temp directory..."
Write-Output "  Source: $hookTemplatesDir"
Write-Output "  Target: $hookTempDir"
Copy-Files -sourceDir $hookTemplatesDir -targetDir $hookTempDir
Write-Output "Copying spawn templates to temp directory..."
Write-Output "  Source: $spawnTemplatesDir"
Write-Output "  Target: $spawnTempDir"
Copy-Files -sourceDir $spawnTemplatesDir -targetDir $spawnTempDir

Write-Output "Updating placeholders in template files in temp directories..."
Update-Placeholders -targetDir $spawnTempDir -oldText "GITHUB_ACCOUNT" -newText $githubAccount 
Update-Placeholders -targetDir $spawnTempDir -oldText "BRANCH_NAME" -newText $currentBranch 
Update-Placeholders -targetDir $hookTempDir -oldText "GITHUB_ACCOUNT" -newText $githubAccount
Update-Placeholders -targetDir $hookTempDir -oldText "BRANCH_NAME" -newText $currentBranch    

Write-Output "Copying updated template files to target directories..."
Copy-Files -sourceDir $hookTempDir -targetDir $hookTargetDir
Copy-Files -sourceDir $spawnTempDir -targetDir $spawnTargetDir

Write-Output "Adding a .gitignore file to the spawn directory to avoid pushing local config back to origin..."
$gitIgnore = Join-Path -Path $spawnTargetDir -ChildPath ".gitignore"
New-Item $gitIgnore -ItemType File | Out-Null
Set-Content -Path $gitIgnore -Value "*"

Write-Output "Removing temp directories..."
Remove-Item -Path $hookTempDir -Recurse -Force
Remove-Item -Path $spawnTempDir -Recurse -Force