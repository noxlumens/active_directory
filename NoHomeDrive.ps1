#OUs to exclude
$ouToExclude = 'OU=SERVICE ACCOUNTS,OU=Domain USERS,DC=Domain,DC=com'
Write-Host "Checking for Users without a Home directory...`n"
#Get all users with no home directory that are not temp employees or service accounts
Get-ADUser -Filter 'enabled -eq $true' -SearchBase 'OU=Users,DC=Domain,DC=com' -Properties Title, ProfilePath, HomeDirectory,HomeDrive | Where-Object { $_.HomeDrive -eq $null -and $_.Title -notlike "TEMP*" -and $_.DistinguishedName -notlike "*,$ouToExclude" } | Select-Object Name, SamAccountName, Title | Export-CSV -Path "$env:userprofile\Desktop\NoHomeDirectoryUsers.csv" -Force

#Output File to the following directory
Write-Host "`nOutput Saved to: $env:userprofile\Desktop\NoHomeDirectoryUsers.csv`n"
