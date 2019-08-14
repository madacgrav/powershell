 param
 (
 [string] $feedName="",
 [string] $packageId="",
 [string] $packageVersion="",
 [string] $packageQuality="Release"
 )

$username = ""
$PAT = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))

$releaseViewURL = "https://<yo>.pkgs.visualstudio.com/DefaultCollection/_apis/packaging/feeds/$feedName/nuget/packages/$packageId/versions/$packageVersion/?api-version=3.0-preview"
 
 #Queue a new build for this definition
 $json = @"
 {
 "views": 
 { "op":"add", 
 "path":"/views/-", 
 "value":"$packageQuality" }
 },
"@

$chatresult = @{}

try {
    $response = Invoke-RestMethod -Uri $releaseViewURL -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Method Patch -Body $json
    $chatresult.output = "*$($packageId)* - $packageVersion promoted to Release."
    $chatresult.success = $true
}
catch {
  #  write-output $_.Exception.Message
   # write-output "Shit broke: $_.Message"
    $chatresult.output = "*$($packageId)* - error on code promotion."
    $chatresult.success = $false
}

return $chatresult | ConvertTo-Json