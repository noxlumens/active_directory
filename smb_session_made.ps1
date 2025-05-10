# Set as Schedule Task to monitor smb connections made to your workstation
# Define the whitelist of ClientUserNames
$whitelist = @("Domain\userName")

while ($true) {
    # Initialize an empty array to store the current SMB sessions
    $currentSessions = @()
    
    # Get the current SMB sessions
    $smbSessions = Get-SmbSession
    
    # Compare the current SMB sessions with the previous ones
    $newSessions = $smbSessions | Where-Object { $_.ClientUserName -notin $currentSessions.ClientUserName }
    
    # Check if any of the current sessions are in the whitelist
    if ($currentSessions.ClientUserName -in $whitelist) {
        continue
    } else {
        # If there are any new sessions, display a popup for each one
        foreach ($session in $newSessions) {
            if ($session.ClientUserName -notin $whitelist) {
                # Create a new shell object for the popup
                $wshell = New-Object -ComObject Wscript.Shell
                $wshell.Popup("User $($session.ClientUserName) connected to your computer")
            }
        }

        # Update the current sessions
        $currentSessions = $smbSessions

        # Wait for a while before checking again
        Start-Sleep -Seconds 300
    }
}
