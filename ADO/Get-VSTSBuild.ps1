$releaseID = ($OctopusParameters['Octopus.Release.Number']).Split(".")
$buildID = $releaseID[3]
$buildID = $buildID -replace "-[hotfix].+", ""
$buildID = $buildID -replace "-[v].+", ""
Set-OctopusVariable -name "VSTSbuildID" -value $buildID

$buildID = ""

write-output $buildID
$username = ""
$PAT = "*****"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$PAT)))
$apiUrl = "https://<yo>.visualstudio.com/DefaultCollection/<yo>/_apis/build/builds/" + $buildID + "/timeline?api-version=2.0"
$buildInfo = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method GET  -ContentType application/json

foreach($record in $buildInfo.records) {
    if ($record.Name -eq "Get Sources") {
        $log = Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri $record.log.url -usebasicparsing
    }    
} 

write-output "Build Information"
write-output $log.Content

out-file -inputobject $log.Content "C:\!IT\OutPut\GetSourcesLog.txt"
$unformatedstring = Get-content "C:\!IT\OutPut\_GetSourcesLog.txt"

$formatedlog = "<style type='text/css'><!--.tab { margin-left: 40px; }--></style><p class='tab'><i>"
foreach ($line in $unformatedstring) {
    $formatedlog = $formatedlog + "<br>" + $line
}

$formatedlog = $formatedlog + "</i></p>"


Set-OctopusVariable -name "VSTSLog" -value $formatedlog

