param(
    [Parameter(Mandatory=$false, HelpMessage="Enter the User's Name e.g., 'firstName lastName'")]
    [string]$username,

    [Parameter(Mandatory=$false, HelpMessage="Want to get the user's group memberships?")]
    [switch]$g,

    [Parameter(Mandatory=$false, HelpMessage="Set a Temporary Password for the Defined User. Ensure you have the EXACT user or you risk changing multiple User Passwords")]
    [switch]$r,

    [Parameter(Mandatory=$false, HelpMessage="Disable a User Account. Ensure you have the EXACT username.")]
    [switch]$d,

    [Parameter(Mandatory=$false)]
    [switch]$h
)

$global:username = $username.ToLower()

Write-Host "
Welcome $env:username,
78 79 88 76 85 77 69 78 83 
6E 6F 78 6C 75 6D 65 6E 73
"

if ($h) {
    Write-Host "Mandatory Flags:`n-u or -username 'FlastName', 'firstName *', '* lastName'`nOptional Flags:`n-g 'Returns the User's Group Memberships'`n-r 'Set a temporary password for the defined User'`n-d 'Disable Selected User account'"
} elseif ($username -and -not $g -and -not $r -and -not $d ) {
    try {
        if ($username -match '^\S+\s\S+$') { # Checks if $username is two words separated by a space
            $user = Get-ADUser -Filter "Name -like '$username'" -Properties Name, SamAccountName, EmailAddress, UserPrincipalName, PasswordLastSet, PasswordExpired, LockedOut |
            Select-Object Name, SamAccountName, EmailAddress, UserPrincipalName, PasswordLastSet, PasswordExpired, LockedOut
            Write-Host "Searching for $username"
            if ($user.LockedOut -eq $true) {
                $unlockAccount = Read-Host "Do you want to unlock the account for '$($user.Name)'? (y/n)"
                if ($unlockAccount -ieq 'y') {
                    Unlock-ADAccount -Identity $user.SamAccountName
                    Write-Host "$($user.SamAccountName) has been unlocked."
                } else {
                    Write-Host "You chose to not unlock the account."
                }
            } else {
                $user
            }
        } elseif ($username -match '^\S+$') { # Checks if $username is one word
            $user = Get-ADUser -Identity $username -Properties Name, SamAccountName, EmailAddress, UserPrincipalName, PasswordLastSet, PasswordExpired, LockedOut |
            Select-Object Name, SamAccountName, EmailAddress, UserPrincipalName, PasswordLastSet, PasswordExpired, LockedOut
            Write-Host "Searching for $username"
            if ($user.LockedOut -eq $true) {
                $unlockAccount = Read-Host "Do you want to unlock the account for '$($username)'? (y/n)"
                if ($unlockAccount -ieq 'y') {
                    Unlock-ADAccount -Identity $user.SamAccountName
                    Write-Host "The account has been unlocked."
                } else {
                    Write-Host "You chose to not unlock the account."
                }
            } else {
                $user
            }
        } else {
            Write-Host "Invalid username format. Please try again!"
        }
    }
    catch {
        return $_
    }
} elseif ($username -and $g) { 
    $users = Get-ADUser -Filter "(Name -like '$username') -or (SamAccountName -like '$username')" -Properties *

    foreach ($user in $users) {
        # Display the user's name
        Write-Host "`nUser: $($user.Name)"
    
        # Display the user's group memberships
        Write-Host "Group Memberships:"
        $user | Select-Object -ExpandProperty MemberOf | ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object -Unique
    }
} elseif ($username -and $r) {
    $users = Get-ADUser -Filter "(Name -like '$username') -or (SamAccountName -like '$username')"
    
    #  RESET USER PASSWORD
    if ($users.Count -gt 1) {
        foreach ($user in $users) {
            Write-Host "$user`n"
        }
        Write-Host "!!!!!YOU'RE TRYING TO RESET THE PASSWORD FOR MORE THAN ONE USER!!!!!"
        exit
    } else {
        foreach ($user in $users) {
            try {
                $confirmReset = Read-Host "Confirm password reset for $username! (y,n)"

                if ($confirmReset -ieq 'y') {
                    Write-Host "Setting a Temporary password for $username`n"
                    $temporaryPassword = Read-Host ("Enter Temporary Password for $username")
                    Write-Host "`n----------`n`nTemporary password: $temporaryPassword`n$username needs to change their password!`n`n----------" 
                    Set-ADAccountPassword -Identity $username -NewPassword (ConvertTo-SecureString -AsPlainText $temporaryPassword -Force) -Reset
                } else {
                    Write-Host "You chose to not set a temporary password for $username."
                } 
            }
            catch {
                $_ | Format-List -Force
                exit $LASTEXITCODE
            }
        }
    } 
} elseif ($username -and $d) { 
    $users = Get-ADUser -Filter "(Name -like '$username') -or (SamAccountName -like '$username')"
    
    foreach ($user in $users) {
        # Display the user's name
        Write-Host "`nUser: $($user.Name)"
                
        # Display the user's group memberships
        Write-Host "Disabling User: $($user.SamAccountName)`nWaiting 5 Seconds to perform action....................."
        Start-Sleep(5)
        Write-Host "Here we go!"
        Disable-ADAccount -Identity $user.SamAccountName
        $user = Get-ADUser -Identity $user.SamAccountName -Properties Name, SamAccountName, EmailAddress, UserPrincipalName, PasswordLastSet, PasswordExpired, Enabled | Select-Object Name, SamAccountName, EmailAddress, UserPrincipalName, PasswordLastSet, PasswordExpired, Enabled
        Write-Output $user
    }
} else {
    Write-Host "Mandatory Flags:`n-u or -username 'lastName', 'firstName *', '* lastName'`nOptional Flags:`n-g 'Returns the User's Group Memberships'`n-r 'Set a temporary password for the defined User'`n-d 'Disable Selected User account'"
}
