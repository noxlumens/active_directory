# 01 Installing the Domain Controller 

1. User 'sconfig' to:
    - Change the hostname
    - Change the IP address to static
    - Change the DNS server to its own IP address

2. Install the Active Directory Windows Feature


```shell
Install-WindowsFeature AD-Domain-Services - IncludeManagementTools
```