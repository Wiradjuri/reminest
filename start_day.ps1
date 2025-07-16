# start_day.ps1
# Set date format to YYYYMMDD
$today = Get-Date -Format "yyyyMMdd"

# Checkout main and pull latest
git checkout main
git pull origin main

# Create and switch to new dev branch for today
$branchName = "dev-$today"
git checkout -b $branchName

# Push branch to remote
git push -u origin $branchName

Write-Host "`n✅ Started new branch: $branchName"
