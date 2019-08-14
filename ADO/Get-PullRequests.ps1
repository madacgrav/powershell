
$username = ""
$PAT = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
$apiUrl = "https://dev.azure.com/<dfdfsdfd>/_apis/git/pullrequests?api-version=4.1"
$prs = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET  -ContentType application/json
#$prs


foreach ($pr in $prs.value) {

    $pr.repository.name
    write-output ("https://<company>.visualstudio.com/<collection>/" + $pr.repository.name + "/pullrequest/" + $pr.pullRequestId + "?_a=overview")
}
$prs.count

