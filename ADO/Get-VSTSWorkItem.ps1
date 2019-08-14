

$username = ""
$PAT = ""

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
#$apiUrl = "https://<doh>.visualstudio.com/DefaultCollection/_apis/wit/workitems/11141?`$expand=relations&api-version=1.0"
$apiUrl = "https://<doh>.visualstudio.com/DefaultCollection/_apis/wit/workitems/11141?api-version=1.0"
#Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET  -ContentType application/json

$json = @"
[
    {
        "op": "test",
        "path": "/rev",
        "value": 3
      },
    {
      "op": "add",
      "path": "/fields/System.State",
      "value": "In Progress"
    },
    {
      "op": "add",
      "path": "/fields/System.History",
      "value": "changed state via api x 2"
    }
  ]
"@

Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method PATCH -Body $json -ContentType application/json-patch+json
