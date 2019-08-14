Param(
    [string]$buildName,
    [string]$slackchannel
  )
  

$username = ""
$PAT = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
$apiUrlListBuilds = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/definitions?api-version=2.0"
$apiUrlQueueBuild = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/builds?api-version=2.0"
$buildFound = $false

$builddefs = Invoke-RestMethod -Uri $apiUrlListBuilds -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET  -ContentType application/json
#$builddefs

foreach ($def in $builddefs.Value) {
    if ($def.Name -eq $buildName) {
        $buildDefiD = $def.Id
        $buildFound = $true
      #  write-output "found"
    }
}


$json = @"
{
    "definition": {
      "id": $buildDefiD
    },
    "sourceBranch": "refs/heads/stable"
  },
"@

$result = @{}


if ($buildFound) {
    
    try {
        $runbuild = Invoke-RestMethod -Uri $apiUrlQueueBuild -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method Post -Body $json  -ContentType application/json
        $result.output = "Build *$($buildName)* - Started."
        $result.success = $true
    }
    catch {
        $result.output = "Build *$($buildName)* - Error starting build. @agraves- please review."
        $result.success = $false
    }
}
else {
    $result.output = "Build *$($buildName)* - Not Found."
    $result.success = $false
}


return $result | ConvertTo-Json