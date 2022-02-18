
#This enabling only explorer and edge browser SSO

Get-ADFSProperties

Set-ADFSProperties –ExtendedProtectionTokenCheck None

Set-AdfsProperties -WIASupportedUserAgents @("MSIE 6.0", "MSIE 7.0; Windows NT", "MSIE 8.0", "MSIE 9.0", "MSIE 10.0; Windows NT 6", "Windows NT 6.3; Trident/7.0", "Windows NT 6.3; Win64; x64; Trident/7.0", "Windows NT 6.3; WOW64; Trident/7.0", "Windows NT 6.2; Trident/7.0", "Windows NT 6.2; Win64; x64; Trident/7.0", "Windows NT 6.2; WOW64; Trident/7.0", "Windows NT 6.1; Trident/7.0", "Windows NT 6.1; Win64; x64; Trident/7.0", "Windows NT 6.1; WOW64; Trident/7.0","Windows NT 10.0; WOW64; Trident/7.0", "MSIPC", "Windows Rights Management Client", "=~Windows\s*NT.*Edg.*")
$FormatEnumerationLimit=-1Get-ADFSProperties


#Add firefox and Crome on WIA 
Set-AdfsProperties -WIASupportedUserAgents ((Get-ADFSProperties | Select -ExpandProperty WIASupportedUserAgents) + "Chrome" + "Firefox")
