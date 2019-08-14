##CONFIG##
$OctopusURL = "deploy" #Octopus URL
$OctopusAPIKey = "API-" #Octopus API Key
$ProjectName = "" #Project to delete
$EnvironmentID = "Environments-1"
##PROCESS##
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$allprojects = (Invoke-WebRequest $OctopusURL/api/environments/all -Method Get -Headers $header).content | ConvertFrom-Json

foreach($project in $allprojects) {
        $project.Name
        $project.ID
}

