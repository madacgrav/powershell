[CmdletBinding()]
Param(
  [string]$releaseversion
)

#$projectID = "Projects-2"

$OctopusAPIKey = "*****"
$OctopusURL = "*****"

$header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }

# customise the fields below as required:
$body = @{
  ProjectId = "Projects-2"
  Version = $releaseversion
  ReleaseNotes = "auto release creation"
  ChannelId = "Channels-4"
  SelectedPackages = @(
    @{
      StepName = "Deploy Package WebService"
      Version = $releaseversion
    }
    @{
        StepName = "Deploy Package Web"
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
  #$Result = $_.Exception.Response.GetResponseStream()
  #$Reader = New-Object System.IO.StreamReader($result)
  #$ResponseBody = $Reader.ReadToEnd();
  #$Response = $ResponseBody | ConvertFrom-Json
 # $Response.Errors
  write-output $_.Exception
}

$slackuri = "https://hooks.slack.com/services/"

	$payload = @{
		"channel" = "#deployments"
		"color" = "#36a64f"
		"icon_emoji" = ":floppy_disk:"
		"text" = "***"
		"username" = "user"
	}

	Invoke-WebRequest `
	-Body (ConvertTo-Json -Compress -InputObject $payload) `
	-Method Post `
	-Uri $slackuri -UseBasicParsing | Out-Null