# end_day.ps1
# Get current branch
$currentBranch = git branch --show-current

# Stage all changes
git add .

# Commit work
$commitMessage = Read-Host "Enter commit message"
git commit -m "$commitMessage"

# Push to remote
git push origin $currentBranch

Write-Host "`n✅ Work committed and pushed to branch: $currentBranch"

