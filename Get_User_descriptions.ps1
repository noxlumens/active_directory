# Define the LDAP path
$LDAPPath = "LDAP://DC=DOMAIN,DC=local"

# Create a DirectorySearcher object
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = [ADSI]$LDAPPath
$searcher.Filter = "(&(objectCategory=person)(objectClass=user))"

# Specify the properties to load
$searcher.PropertiesToLoad.Add("name")
$searcher.PropertiesToLoad.Add("description")

# Execute the search
$results = $searcher.FindAll()

# Iterate through the results and display the properties
foreach ($result in $results) {
    $user = $result.Properties
    $fname = if ($user["name"]) { $user["name"][0] } else { "(No Value)" }
    $description = if ($user["description"]) { $user["description"][0] } else { "(No Value)" }
    
    Write-Output "First Name: $fname"
    Write-Output "Description: $description"
}

# Clean up
$searcher.Dispose()
