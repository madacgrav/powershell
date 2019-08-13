
Param(
    [string]$blobname,
    [switch]$verbose
  )


import-module Posh-SSH
if($verbose) { $VerbosePreference = "continue" }

$chatresult = @{}
$username = "user"
$password = "password"

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

$session = New-SSHSession -ComputerName hcbbswarm01.eastus.cloudapp.azure.com -KeyFile "C:\keyfilessh" -port 2200 -Credential $mycreds  -Force

$command1 = "export BLOB_NAME='$blobname'"
$command2 = "docker pull <imageName>"
$command3 = "docker run --env-file <filename> -e BLOB_NAME <imagename>"
try {
    $command = Invoke-SSHCommand -Index 0 -Command "$command1; $command2; $command3"
    $chatresult.output = $command.output
    $chatresult.success = $true  
}
catch {
    write-verbose $_.Exception.Message

    $chatresult.output = "error staring docker"
    $chatresult.success = $false  
}

return $chatresult | ConvertTo-Json