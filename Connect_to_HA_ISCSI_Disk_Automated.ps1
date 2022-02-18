
$localnode = "node2"

if($localnode -eq "node1"){
#Node1 Params

$localNodeIqn = "iqn.2008-08.com.starwindsoftware:hci-node1.kotiverkko.net-"
$localNodeAddress = "100.10.10.11","100.10.20.11","100.10.30.11","100.10.40.11"

$externalNodeIqn = "iqn.2008-08.com.starwindsoftware:hci-node2.kotiverkko.net-"
$externalNodeAddress = "100.10.10.12","100.10.20.12","100.10.30.12","100.10.40.12"

$diskTargetName = "test02"
$mpioConnectionLocal = 6
$mpioConnectionExternal = 2
}
Elseif($localnode -eq "node2"){
#Node2 Params

$localNodeIqn = "iqn.2008-08.com.starwindsoftware:hci-node2.kotiverkko.net-"
$localNodeAddress = "100.10.10.12","100.10.20.12","100.10.30.12","100.10.40.12"

$externalNodeIqn = "iqn.2008-08.com.starwindsoftware:hci-node1.kotiverkko.net-"
$externalNodeAddress = "100.10.10.11","100.10.20.11","100.10.30.11","100.10.40.11"

$diskTargetName = "test02"
$mpioConnectionLocal = 6
$mpioConnectionExternal = 2
}

#Show all available targets 
Get-IscsiTarget | ft -AutoSize -Wrap 

#Enable ISCSI IF not Enabled
If(!((Get-service msiscsi).status -eq "running")) {
    start-service msiscsi
    Set-Service msiscsi –StartupType “Automatic”
}

#Set Global load balance policy to Least Queue Depth
$loadBalancePolicy = Get-MSDSMGlobalDefaultLoadBalancePolicy
If(!($loadBalancePolicy -eq "LQD")) {
    Set-MSDSMGlobalDefaultLoadBalancePolicy -Policy LQD
}

#Configure ISCSI Target Portal [LOCAL]
$localTargetPortal = Get-IscsiTargetPortal | Where-Object TargetPortalAddress -eq 127.0.0.1
If($localTargetPortal -eq $null) {
    New-IscsiTargetPortal –TargetPortalAddress 127.0.0.1 -InitiatorInstanceName "ROOT\ISCSIPRT\0000_0"
}
Elseif(!($localTargetPortal -eq $null) -and !($localTargetPortal).InitiatorInstanceName -eq "ROOT\ISCSIPRT\0000_0") {
    Remove-IscsiTargetPortal –TargetPortalAddress 127.0.0.1 -Confirm:$False
    New-IscsiTargetPortal –TargetPortalAddress 127.0.0.1 -InitiatorInstanceName "ROOT\ISCSIPRT\0000_0"
}

#Configure ISCSI Target Portal [External 1]
$partnerTargetPortal = Get-IscsiTargetPortal | Where-Object TargetPortalAddress -eq $externalNodeAddress[0]
If($partnerTargetPortal -eq $null) {
    New-IscsiTargetPortal –TargetPortalAddress $externalNodeAddress[0] -InitiatorPortalAddress $localNodeAddress[0] -InitiatorInstanceName "ROOT\ISCSIPRT\0000_0"
}
Elseif(!($partnerTargetPortal -eq $null) -and !($partnerTargetPortal).InitiatorInstanceName -eq "ROOT\ISCSIPRT\0000_0") {
    Remove-IscsiTargetPortal –TargetPortalAddress $externalNodeAddress[0] -Confirm:$False
    New-IscsiTargetPortal –TargetPortalAddress $externalNodeAddress[0] -InitiatorPortalAddress $localNodeAddress[0] -InitiatorInstanceName "ROOT\ISCSIPRT\0000_0"
}
Elseif(!($partnerTargetPortal -eq $null) -and ($partnerTargetPortal).InitiatorInstanceName -eq "ROOT\ISCSIPRT\0000_0" -and !($partnerTargetPortal).InitiatorPortalAddress -eq $localNodeAddress[0]) {
    Remove-IscsiTargetPortal –TargetPortalAddress $externalNodeAddress[0] -Confirm:$False
    New-IscsiTargetPortal –TargetPortalAddress $externalNodeAddress[0] -InitiatorPortalAddress $localNodeAddress[0] -InitiatorInstanceName "ROOT\ISCSIPRT\0000_0"
}


#CONNECT TO HA TARGET

$localNodeFullTargetName = $localNodeIqn + $diskTargetName
$externalNodeFullTargetName = $externalNodeIqn + $diskTargetName

#Connect to Target and make it persistent [Local]
for ($u=0; $u -lt $mpioConnectionLocal; $u++) {
    Connect-IscsiTarget -NodeAddress $localNodeFullTargetName -TargetPortalAddress "127.0.0.1" -IsMultipathEnabled $True -IsPersistent $True
}

#Connect to Target and make it persistent [External]
for ($i=0; $i -lt $mpioConnectionExternal; $i++) {
    Foreach ($externalAddress in $externalNodeAddress) {

            Connect-IscsiTarget -NodeAddress $externalNodeFullTargetName -TargetPortalAddress $externalAddress -InitiatorPortalAddress $localNodeAddress[$externalNodeAddress.IndexOf($externalAddress)] -IsMultipathEnabled $True -IsPersistent $True
    }
}

