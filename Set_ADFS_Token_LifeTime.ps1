
Add-PSSnapin Microsoft.Adfs.PowerShell

Get-ADFSRelyingPartyTrust –Name "Kotiverkko Portal"

Get-ADFSRelyingPartyTrust –Name "OneDrive"

Set-ADFSRelyingPartyTrust –TargetName "Kotiverkko Portal" –TokenLifetime 1200

Set-ADFSRelyingPartyTrust –TargetName "OneDrive" –TokenLifetime 1200
