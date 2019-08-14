[CmdletBinding()]
Param(
    [string]$buildID = "9950",
    [string]$buildName = "TestTest",
    [string]$channel 
)

$username = ""
$PAT = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
$apiUrl = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/builds/" + $buildID + "/timeline?api-version=2.0"
$buildInfo = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET  -ContentType application/json

$tasklist = ""
$issues = $false
$errors = $false
$buildUrl = "https://<yo>.visualstudio.com/<yo>/,prj>/_build/index?buildId=" + $buildID + "&_a=summary"
$slackuri = "https://hooks.slack.com/services/"

foreach ($record in $buildInfo.Records) {
    
    if ($record.Name -ne "SlackOutput") {
        $tasklist = $tasklist + $record.Name + ":" + $record.Result + "`n"
        if ($record.Result -eq "succeededWithIssues") {$issues = $true}
        if ($record.Result -eq "failed") {$errors = $true}
    }
}

if ($errors) {$buildResult = ":sos:"}
elseif ($issues) {$buildResult = ":construction:"}
else {$buildResult = ":white_check_mark:"}

if (!($channel -eq "")) {
    $channel = "#" + $channel
    $slacktext = $buildResult + "<$buildUrl|Results of $buildName>"
    $payload = @{
        "channel" = $channel
        "color" = "#36a64f"
        "icon_emoji" = ":bluebook:"
        "text" = $slacktext
        "username" = "VSTS"
    }
    Invoke-WebRequest `
    -Body (ConvertTo-Json -Compress -InputObject $payload) `
    -Method Post `
    -Uri $slackuri -usebasicparsing | Out-Null
}