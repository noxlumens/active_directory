param (
    [Alias("i")]
    [Parameter(Mandatory=$false)]
    [string]$Identity,

    [Alias("p")]
    [Parameter(Mandatory=$false)]
    [switch]$History,

    [Alias("r")]
    [Parameter(Mandatory=$false)]
    [switch]$Reset,

    [Alias("v")]
    [Parameter(Mandatory=$false)]
    [switch]$CustomVerbose,

    [switch]$Help
)
Import-Module LAPS

# Function to display usage information
function Show-Usage {
    Write-Host "Usage:`nget-laps.ps1 -i <ComputerName>`nget-laps.ps1 -i <ComputerName> -r [Reset LAPS Password]`nget-laps.ps1 -i <ComputerName> -v [Run Command Verbose]`nget-laps.ps1 -i <ComputerName> -p [Include Password History]`n`n[Mandatory: ]`n-i <Identity> (Computer Hostname)`n[Optional: ]`n-r Reset LAPS Password for $env:COMPUTERNAME with no option set or <Identity>`n-v Print Verbose Output`n-p Include Password History`n-h Get this help information"
}

# Function to get LAPS password
function Get-LapsPassword {
    param (
        [string]$Identity
    )
    try {
        $result = Get-LapsADPassword -Identity $Identity -AsPlainText -ErrorAction Stop -Verbose:$CustomVerbose | Select-Object -Property ComputerName, Password, ExpirationTimeStamp
        if ($null -eq $result) {
            Write-Host "Computer '$Identity' was not found."
        } else {
            $result
        }
    } catch {
        Write-Host "Computer '$Identity' was not found."
    }
}

# Function to reset LAPS password
function Reset-LapsPasswordFunc {
    param (
        [string]$Identity
    )
    Reset-LapsPassword -Identity $Identity -ErrorAction Continue -Verbose:$CustomVerbose 
}

# Function to prompt for confirmation
function Confirm-Action {
    param (
        [string]$Message
    )
    $confirmation1 = Read-Host "$Message (yes/no)"
    $confirmation2 = Read-Host "Please confirm again: $Message (yes/no)"
    return ($confirmation1 -eq "yes" -and $confirmation2 -eq "yes")
}

# Function to get LAPS password history
function Get-LapsPasswordHistory {
    param (
        [string]$Identity
    )
    try {
        $result = Get-LapsADPassword -Identity $Identity -IncludeHistory -AsPlainText -ErrorAction Stop -Verbose:$CustomVerbose | Select-Object -Property ComputerName, Password, PasswordUpdateTime, ExpirationTimeStamp
        if ($null -eq $result) {
            Write-Host "LAPS not found for: '$Identity'"
        } else {
            $result
        }
    } catch {
        Write-Host "LAPS not found for '$Identity'"
    }
}

# Main script logic
if ($Help) {
    Show-Usage
} elseif (-not $Identity -and -not $Reset -and -not $CustomVerbose -and -not $History) {
    Show-Usage
} elseif ($Reset -and $Identity) {
    if (Confirm-Action "Are you sure you want to reset the LAPS password for the current computer? $env:COMPUTERNAME") {
        Reset-LapsPasswordFunc -Identity $env:COMPUTERNAME
    } else {
        Write-Host "Action cancelled."
    }
} elseif ($Identity -and $History) {
    Get-LapsPasswordHistory -Identity $Identity
} elseif ($Identity) {
    Get-LapsPassword -Identity $Identity
} else {
    Show-Usage
}
