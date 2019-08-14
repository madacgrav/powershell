[CmdletBinding()]
Param(
  [string]$releaseversion,
  [string]$projectID,
  [string]$channelID,
  [string]$stepName
)

#$projectID = "Projects-2"

$OctopusAPIKey = "******"
$OctopusURL = "*****"

$header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }

# customise the fields below as required:
$body = @{
  ProjectId = $projectID
  Version = $releaseversion
  ReleaseNotes = "auto release creation"
  ChannelId = $channelID
  SelectedPackages = @(
    @{
      StepName = $stepName
      Version = $releaseversion
    }
  )
}

try
{
  Invoke-WebRequest $OctopusURL/api/releases?ignoreChannelRules=false -Method POST -Headers $header -Body ($body | ConvertTo-Json)

}
catch
{
  $Result = $_.Exception.Response.GetResponseStream()
  $Reader = New-Object System.IO.StreamReader($result)
  $ResponseBody = $Reader.ReadToEnd();
  $Response = $ResponseBody | ConvertFrom-Json
  $Response.Errors
  write-output $_.Exception
}