##CONFIG##
$OctopusURL = "deploy.hcbb.org" #Octopus URL
$OctopusAPIKey = "API-" #Octopus API Key
$ProjectName = "LIE" #Project to delete
$EnvironmentID = "Environments-1"
##PROCESS##
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$allprojects = (Invoke-WebRequest $OctopusURL/api/projects/all -Method Get -Headers $header).content | ConvertFrom-Json

foreach($project in $allprojects) {
    if($project.Name -eq $ProjectName) {
        $project.Name
        $ProjectID = $project.ID
    }
}

$ProjectDashboardReleases = (Invoke-WebRequest $OctopusURL/api/progression/$ProjectID -Method Get -Headers $header).content | ConvertFrom-Json

$ProjectDashboardReleases.Releases.Deployments.$EnvironmentId

#$LastSuccessfullRelease = $ProjectDashboardReleases.Releases.Deployments.$EnvironmentId | ?{$_.state -eq "Success" -and $_.IsCurrent -eq $true}

#$LastSuccessfullRelease

