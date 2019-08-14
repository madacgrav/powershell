##CONFIG##
$OctopusURL = "****" #Octopus URL
$OctopusAPIKey = "****" #Octopus API Key

##PROCESS##
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }


$environments = (Invoke-WebRequest $OctopusURL/api/environments/all -Method Get -Headers $header).content | ConvertFrom-Json


$projects = (Invoke-WebRequest $OctopusURL/api/projects/all -Method Get -Headers $header).content | ConvertFrom-Json


foreach ($project in $projects) {
       # $project.ID
        $id = $project.ID

        $ProjectDashboardReleases = (Invoke-WebRequest $OctopusURL/api/progression/$id -Method Get -Headers $header).content | ConvertFrom-Json
        foreach ($environment in $environments) {
                $LastSuccessfullRelease = $ProjectDashboardReleases.Releases.Deployments.($environment.id) | ?{$_.state -eq "Success"} | select -First 1
                if ($LastSuccessfullRelease) {
                        write-host ("Project Name: " + $project.name + " Environment: " + $environment.name + " Version: " + $LastSuccessfullRelease.ReleaseVersion)                 
                }
        }

}




