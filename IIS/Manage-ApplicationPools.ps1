Param(
    [string]$server,
    [string]$action,
    [string]$appPoolName
)

$result = @{ }


$username = "<user>"
$secpassword = ConvertTo-SecureString "<password>" -AsPlainText -Force
$domain = "<domain name>"

$mycreds = New-Object System.Management.Automation.PSCredential ($username, $secpassword)
$s = New-PSSession -ComputerName $server -Credential $mycreds


$response = Invoke-Command -Session $s -ScriptBlock {
    param($appPool, $actionType)
    try {
        $initial = Get-WebAppPoolState -Name $appPool
        switch ($actionType) {
            "start" {
                if ($initial.Value -ne "Started") {
                    write-verbose "Starting AppPool $appPool"
                    Start-WebAppPool -Name $appPool
                    Start-Sleep -s 3
                    $appPoolInfo = Get-WebAppPoolState -Name $appPool
                    if ($appPoolInfo.Value -eq "Started") {
                        return ("success,$appPool is " + $appPoolInfo.Value)
                    }
                    else {
                        return ("failure,$appPool is " + $appPoolInfo.Value)
                    }
                }
                else {
                    return ("failure,$appPool is already started")
                }

            }
            "stop" { 
                if ($initial.Value -ne "Stopped") {
                    write-verbose "Stopping AppPool $appPool"
                    Stop-WebAppPool -Name $appPool
                    Start-Sleep -s 3
                    $appPoolInfo = Get-WebAppPoolState -Name $appPool
                    if ($appPoolInfo.Value -eq "Stopped") {
                        return ("success,$appPool is " + $appPoolInfo.Value)
                    }
                    else {
                        return ("failure,$appPool is " + $appPoolInfo.Value)
                    }
                }
                else {
                    return ("failure,$appPool is already stopped")
                }
            }
            "restart" { 
                if ($initial.Value -eq "Started") {
                    write-verbose "Restarting AppPool $appPool"
                    Restart-WebAppPool -Name $appPool
                    Start-Sleep -s 3
                    $appPoolInfo = Get-WebAppPoolState -Name $appPool
                    if ($appPoolInfo.Value -eq "Started") {
                        return ("success,$appPool is restarted")
                    }
                    else {
                        return ("failure,$appPool is " + $appPoolInfo.Value)
                    }
                }
                else {
                    write-verbose "Starting AppPool $appPool as it was stopped."
                    Start-WebAppPool -Name $appPool
                    Start-Sleep -s 3
                    $appPoolInfo = Get-WebAppPoolState -Name $appPool
                    if ($appPoolInfo.Value -eq "Started") {
                        return ("success,$appPool was stopped but has been " + $appPoolInfo.Value)
                    }
                    else {
                        return ("failure,$appPool is " + $appPoolInfo.Value)
                    }
                }
            }
        }
    }
    catch {
        return ("failure,$appPool is not found")
    }

} -ArgumentList $appPoolName, $action


$adjust = $response.Split(",")

switch ($adjust[0]) {
    "success" { $result.success = $true }
    "failure" { $result.success = $false }
}
$result.output = $adjust[1]

#$result
return $result | ConvertTo-Json