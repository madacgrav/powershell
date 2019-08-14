Param(
    [string]$search
  )

#Constants
$apiKey = "*****"
$OctopusURL = "OD url"


##PROCESS##
$Header =  @{ "X-Octopus-ApiKey" = $apiKey }
$result = @{}
$list = " "



$ProjectID = $OctopusParameters['Octopus.Project.ID']
$EnvironmentID = $OctopusParameters['Octopus.Environment.ID']

$ProjectDashboardReleases = (Invoke-WebRequest $OctopusURL/api/progression/$ProjectID -Method Get -Headers $header).content | ConvertFrom-Json

$LastSuccessfullRelease = $ProjectDashboardReleases.Releases.Deployments.$EnvironmentId | ?{$_.state -eq "Success"} | select -First 1

$LastSuccessfullRelease.ReleaseVersion



#Getting Project
Try{
    $Projects = Invoke-WebRequest -Uri "$OctopusURL/api/projects/Projects-5/releases" -Headers $Header -ErrorAction Ignore| ConvertFrom-Json
    $Projects
   # $result.output = "Deployments List ``````" + $list + "``````"
   # $result.success = $true
}
catch {
    #$result.output = ":sos: Deployment Query Error.  Check with DevOps Admin"
    #$result.success = $false
}

#return $result | ConvertTo-Json