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

try {
    $smoke = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method Post -Body $json  -ContentType application/json
}
catch {
    $message = ":sos: Queueing Smoke Test failed for $buildDefiD . Error: " + $_.Exception.Message
    PostTo-Slack $message "VSTS" $channel
}






