
if (!(Test-Connection -ComputerName NAT-02V -Count 10)) {

$wanip = (Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias WAN).IPAddress

(Invoke-WebRequest "https://dynamicdns.park-your-domain.com/update?host=(Censored)&domain=(Censored)&password=(Censored)&ip=$wanip").StatusDescription

Write-EventLog -log SMTP_Proxy_Log -source DynamicIp -EntryType Warning -eventID 20 -Message "SMTP PROXY NAT-02V is DOWN, Now main SMTP PROXY is NAT-01V."

}
else {

$wanip = (Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias WAN).IPAddress

(Invoke-WebRequest "https://dynamicdns.park-your-domain.com/update?host=(Censored)&domain=(Censored)&(Censored)&ip=$wanip").StatusDescription

Write-EventLog -log SMTP_Proxy_Log -source DynamicIp -EntryType Information -eventID 10 -Message "All SMTP PROXYs are running and NAT-01V is main SMTP PROXY."

}
