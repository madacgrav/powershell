
function PostTo-Slack ([string]$slacktext, [string]$slackuser, [string]$slackChannel) {
    $slackChannel = "#" + $slackChannel
    $slackuri = "https://hooks.slack.com/services/"
    $payload = @{
        "channel" = $slackChannel
        "color" = "#36a64f"
        "icon_emoji" = "::"
        "text" = $slacktext
        "username" = $slackuser
    }
    Invoke-WebRequest `
    -Body (ConvertTo-Json -Compress -InputObject $payload) `
    -Method Post `
    -Uri $slackuri -usebasicparsing | Out-Null

}

$username = ""
$PAT = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
$apiUrl = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/builds?api-version=2.0"
# API call to get all of the information about the build from VSTS

$timer = [int]$timelimit

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
        write-output $record.Name 
        if (($record.Name -eq "Build") -or ($record.Name -eq "Phase 1"))  {
            $smokestate = $record.state
            write-output $record.Name
            write-output  $record.state
            $status = $record.result
        }    
    } 
    write-output "Sleep 5 seconds"
    write-verbose $count
    Start-Sleep -s 5
    $count++
} Until (($smokestate -eq "completed") -or ($count -ge $timer) )


if ($status -eq "failed") {
    write-output "Smoke Test Failed"
    if ($notify) {
        $message = ":sos: Smoke Test Failed for build def " + $buildDefiD  + " " + $attention
        PostTo-Slack $message "VSTS" $channel
    } 
}
elseif ($count -ge $timer) {
    write-output "Smoke Test Timed Out.  Took over time limit"
    if ($notify) {
        $message = ":timer_clock: Smoke Test Timed Out.  Took over time limit for build def " + $buildDefiD + " " + $attention
        PostTo-Slack $message "VSTS" $channel
    } 
}
else {
    write-output "Smoke Test Passed"
}







