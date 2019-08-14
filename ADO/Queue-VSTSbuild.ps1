Param 
(
    [string] $buildDefiD = "41"
)

$username = ""
$PAT = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
$apiUrl = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/builds?api-version=2.0"
# API call to get all of the information about the build from VSTS

$json = @"
{
    "definition": {
      "id": $buildDefiD
    },
    "sourceBranch": "refs/heads/master",
    
  },
"@

$smoke = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method Post -Body $json  -ContentType application/json
$smoke.id
$buildID = $smoke.Id
$apiUrl = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/builds/" + $buildID + "/timeline?api-version=2.0"
$count = 0
do {
    $buildInfo = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET  -ContentType application/json
    foreach($record in $buildInfo.records) {
        if ($record.Name -eq "Build") {
            $smokestate = $record.state
          #  $record.Name
          #  $record.state
        }    
    } 
    Start-Sleep -s 5
    $count++
} Until (($smokestate -eq "completed") -or ($count -ge 20) )

if ($buildInfo.records[0].result -eq "failed") {
    write-output "Smoke Test Failed"
    exit 1
}
else {
    write-output "Smoke Test Passed"
}






#"parameters": "{\"system.debug\":\"true\",\"BuildConfiguration\":\"debug\",\"BuildPlatform\":\"x64\"}"