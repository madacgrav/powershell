Param(
    [string]$search
  )

#Constants
$apiKey = "*** api key"
$OctopusURL = "OD url"


##PROCESS##
$Header =  @{ "X-Octopus-ApiKey" = $apiKey }
$result = @{}
$list = " "

#Getting Project
Try{
    $Projects = Invoke-WebRequest -Uri "$OctopusURL/api/projects/all" -Headers $Header -ErrorAction Ignore| ConvertFrom-Json
    foreach ($project in $Projects) {
        if ($search) {
            if ($project.Name -like "*$search*") {
                $list = $list + $project.Name + " `n "
            }
        }
        else {
            $list = $list + $project.Name + " `n "
        }
    }
    $result.output = "Deployments List ``````" + $list + "``````"
    $result.success = $true
}
catch {
    $result.output = ":sos: Deployment Query Error.  Check with DevOps Admin"
    $result.success = $false
}

return $result | ConvertTo-Json