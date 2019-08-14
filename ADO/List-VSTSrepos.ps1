
$username = ""
$PAT = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
$apiUrl = "https://dev.azure.com/<uo>/_apis/git/repositories?api-version=5.0"
# API call to get all of the information about the build from VSTS




$repoinfo = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET  -ContentType application/json

foreach ($repo in $repoinfo.value) {
    $repo.Name
}









