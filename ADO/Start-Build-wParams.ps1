[CmdletBinding()]
Param(
    [string]$buildName,
    [string]$previousbuildnum
  )
  



$username = ""
$PAT = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
$apiUrlListBuilds = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/definitions?api-version=2.0"
$apiUrlQueueBuild = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/builds?api-version=2.0"
$buildFound = $false

$builddefs = Invoke-RestMethod -Uri $apiUrlListBuilds -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET  -ContentType application/json

foreach ($def in $builddefs.Value) {
    if ($def.Name -eq $buildName) {
        $buildDefiD = $def.Id
        $buildFound = $true
      #  write-output "found"
    }
}

$json = @"
{
    "parameters":  "{\"primarybuild\":  \"$previousbuildnum\"}",
    "definition": {
      "id": $buildDefiD
    },
  },
"@

$result = @{}

if ($buildFound) {
    
    try {
        $runbuild = Invoke-RestMethod -Uri $apiUrlQueueBuild -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method Post -Body $json  -ContentType application/json
    }
    catch {
        write-verbose "Initiate build failure: " + $_.Exception.Message
        write-output "Initiate build failure: " + $_.Exception.Message
        exit 1
    }
}
else {
    write-verbose "Could not find build"
    write-output "Could not find build"
}

