param(
#Connection param
    $port=3261, 
    $user="root", 
    $password="starwind",
    $port2=$port, 
    $user2=$user, 
    $password2=$password,
#Master Node
    $masterNodeAddr="100.10.10.11",
    $masterNodeIqn = "iqn.2008-08.com.starwindsoftware:hci-node1.kotiverkko.net",
    $masterNodeSyncInterface = "#p1=100.10.10.11:3260,100.10.20.11:3260,100.10.30.11:3260,100.10.40.11:3260",
    $masterNodeHbInterface ="#p1=100.20.10.11:3260,100.20.20.11:3260,100.20.30.11:3260,100.20.40.11:3260",
#Partner Node 
	$partnerNodeAddr="100.10.10.12",
    $partnerNodeIqn = "iqn.2008-08.com.starwindsoftware:hci-node2.kotiverkko.net",
    $partnerNodeSyncInterface = "#p2=100.10.10.12:3260,100.10.20.12:3260,100.10.30.12:3260,100.10.40.12:3260",
    $partnerNodeHbInterface = "#p2=100.20.10.12:3260,100.20.20.12:3260,100.20.30.12:3260,100.20.40.12:3260", 
#Target and Image
	$size=40000,
	$sectorSize=4096,
    $globalImagePath = "My computer\G",
    $globalImageName = "Test05",
    $globalTargetAlias = "Test05",
    $globalPoolName = "TestPool05",
#Cache
    $cacheMode="none",
	$cacheSize=128,
#common
	$initMethod="Clear",
	$failover=0,
#first node
	$imagePath= $globalImagePath,
	$imageName= $globalImageName,
	$createImage=$true,
	$storageName="",    
	$targetAlias= $globalTargetAlias,
	$autoSynch=$true,
	$poolName= $globalPoolName,
	$syncSessionCount=1,
	$aluaOptimized=$true,
	$syncInterface= $partnerNodeSyncInterface,
	$hbInterface= $partnerNodeHbInterface,
	$createTarget=$true,
#secondary node
	$imagePath2= $globalImagePath,
	$imageName2= $globalImageName,
	$createImage2=$true,
	$storageName2="",    
	$targetAlias2= $globalTargetAlias,
	$autoSynch2=$true,
	$poolName2= $globalPoolName,
	$syncSessionCount2=1,
	$aluaOptimized2=$false,
	$cacheMode2=$cacheMode,
	$cacheSize2=$cacheSize,
	$syncInterface2= $masterNodeSyncInterface,
	$hbInterface2= $masterNodeHbInterface,
	$createTarget2=$true
	)
	
#Set target names and force target alias to lowercase
$targetname = $masterNodeIqn + "-" + $globalTargetAlias.ToLower()
$targetname2 = $partnerNodeIqn + "-" + $globalTargetAlias.ToLower()

Import-Module StarWindX

try
{
	Enable-SWXLog

	$server = New-SWServer -host $masterNodeAddr -port $port -user $user -password $password

	$server.Connect()

	$firstNode = new-Object Node

	$firstNode.HostName = $masterNodeAddr
	$firstNode.HostPort = $port
	$firstNode.Login = $user
	$firstNode.Password = $password
	$firstNode.ImagePath = $imagePath
	$firstNode.ImageName = $imageName
	$firstNode.Size = $size
	$firstNode.CreateImage = $createImage
	$firstNode.StorageName = $storageName
	$firstNode.TargetName = $targetname
    $firstNode.TargetAlias = $targetAlias
	$firstNode.AutoSynch = $autoSynch
	$firstNode.SyncInterface = $syncInterface
	$firstNode.HBInterface = $hbInterface
	$firstNode.PoolName = $poolName
	$firstNode.SyncSessionCount = $syncSessionCount
	$firstNode.ALUAOptimized = $aluaOptimized
	$firstNode.CacheMode = $cacheMode
	$firstNode.CacheSize = $cacheSize
	$firstNode.FailoverStrategy = $failover
	$firstNode.CreateTarget = $createTarget
    
	#
	# device sector size. Possible values: 512 or 4096(May be incompatible with some clients!) bytes. 
	#
	$firstNode.SectorSize = $sectorSize
    
	$secondNode = new-Object Node

	$secondNode.HostName = $partnerNodeAddr
	$secondNode.HostPort = $port2
	$secondNode.Login = $user2
	$secondNode.Password = $password2
	$secondNode.ImagePath = $imagePath2
	$secondNode.ImageName = $imageName2
	$secondNode.CreateImage = $createImage2
	$secondNode.StorageName = $storageName2
    $secondNode.TargetName = $targetname2
	$secondNode.TargetAlias = $targetAlias2
	$secondNode.AutoSynch = $autoSynch2
	$secondNode.SyncInterface = $syncInterface2
	$secondNode.HBInterface = $hbInterface2
	$secondNode.SyncSessionCount = $syncSessionCount2
	$secondNode.ALUAOptimized = $aluaOptimized2
	$secondNode.CacheMode = $cacheMode2
	$secondNode.CacheSize = $cacheSize2
	$secondNode.FailoverStrategy = $failover
	$secondNode.CreateTarget = $createTarget2
        
	$device = Add-HADevice -server $server -firstNode $firstNode -secondNode $secondNode -initMethod $initMethod
    
	while ($device.SyncStatus -ne [SwHaSyncStatus]::SW_HA_SYNC_STATUS_SYNC)
	{
		$syncPercent = $device.GetPropertyValue("ha_synch_percent")
	        Write-Host "Synchronizing: $($syncPercent)%" -foreground yellow

		Start-Sleep -m 2000

		$device.Refresh()
	}
}
catch
{
	Write-Host $_ -foreground red 
}
finally
{
	$server.Disconnect()
}

