
    param
    (
        [string[]] $servers,
        [string] $site,
        [string] $ipaddress,
        [string] $cmdtype
    )

$secpasswd = ConvertTo-SecureString "<password>" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ("<user>", $secpasswd)
$result = @{}

$output = ""
$success = $true

function Add-IpDeny () {
    try {
        $ErrorActionPreference = "Stop";
        $s = New-PSSession -ComputerName $server -Credential $creds
        $siteInfo = Invoke-Command -ComputerName $server -Credential $creds  -ScriptBlock {
            param($sitename, $ip)
            Import-Module WebAdministration
            Add-WebConfiguration /system.webServer/security/ipSecurity -location $sitename -value @{ipAddress=$ip;allowed='false'}
        } -args $site , $ipaddress 
        $output = $output + "$ipaddress added to deny on $server `n "
        $success = $true
        Remove-PSSession -Session $s
    }
    catch {
        $output = $output + "Error adding $ipaddress on $server `n "
        $success = $false
    }
    finally{
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}

function List-IpDeny () {
    try {
        $s = New-PSSession -ComputerName $server -Credential $creds
        $siteInfo = Invoke-Command -ComputerName $server -Credential $creds  -ScriptBlock {
            param($sitename)
            Import-Module WebAdministration
            $iplist = Get-WebConfiguration -filter /system.webserver/security/ipsecurity/* -PSPath MACHINE/WEBROOT/APPHOST -location $sitename -Recurse | Where-Object {$_.allowed -eq $false}
            #Add-WebConfiguration /system.webServer/security/ipSecurity -location 'www.healthcarebluebook.com' -value @{ipAddress='50.30.38.241';allowed='false'}
            return $iplist
        } -args $site
        $denylist = ""
        for ($i=0;$i -lt $siteInfo.Count;$i++) {
            $denylist = $denylist + $siteInfo.ipAddress[$i] + " `n "
         }
        
         $result.output = "Blocked IP List ``````" + $denylist + "``````"
         #$result.output = "Test"
         $result.success = $true
         Remove-PSSession -Session $s
    }
    catch {
        $result.output = "Error: " + $_.Exception.Message
        $result.success = $false
        $errors = $true
    
    }

}

function Remove-IpDeny () {}



foreach ($server in $servers) {
    try {
        $ErrorActionPreference = "Stop";
        $s = New-PSSession -ComputerName $server -Credential $creds
        $siteInfo = Invoke-Command -ComputerName $server -Credential $creds  -ScriptBlock {
            param($sitename, $ip)
            Import-Module WebAdministration
            Add-WebConfiguration /system.webServer/security/ipSecurity -location $sitename -value @{ipAddress=$ip;allowed='false'}
        } -args $site , $ipaddress 
        $output = $output + "$ipaddress added to deny on $server `n "
        $success = $true
        Remove-PSSession -Session $s
    }
    catch {
        $output = $output + "Error adding $ipaddress on $server `n "
        $success = $false
    }
    finally{
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
    
}
$result.output = $output
$result.success =  $success

return $result | ConvertTo-Json
