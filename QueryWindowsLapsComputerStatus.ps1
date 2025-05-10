$Hosts = Get-ADComputer -filter 'enabled -eq "true"' -Properties Name, msLAPS-EncryptedPassword

foreach ($computer in $Hosts) {
    #Write-Host "$($computer.Name,$computer."msLAPS-EncryptedPassword")"
    if (-not $computer."msLAPS-EncryptedPassword") {
        Write-Host "[-] $($computer.Name)"
    } else {
        Write-Host "[+] $($computer.Name)"
    }
}
