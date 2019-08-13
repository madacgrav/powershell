
    param
    (
        [string[]] $servers,
        [string] $site,
        [string] $ipaddress
    )

$secpasswd = ConvertTo-SecureString "*****" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ("<user>", $secpasswd)
$result = @{}

$output = ""
$success = $true

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
