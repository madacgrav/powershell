[CmdletBinding()]
Param(
  [string]$projectName,
  [string]$EnvironmentName
)

#Constants
$OctopusAPIKey = "****"
$OctopusURL = "http://****"
$OctoPusWRHeader =  @{ "X-Octopus-ApiKey" = $OctopusAPIKey }

##PROCESS##

$result = @{}

function Find-ProjectID([string]$url, $header, $appName) {
    $projects = Invoke-WebRequest -Uri "$url/api/projects" -Headers $header -ErrorAction Ignore| ConvertFrom-Json
    $projectID = "0"
    foreach ($projectInfo in $projects.Items) {
        if ($appName -eq $projectInfo.Name) {
            $projectID = $projectInfo.Id
        }
    }
    return $projectID
}

function Find-EnvironmentID([string]$url, $header, $envName) {
    $Environment = Invoke-WebRequest -Uri "$url/api/Environments/all" -Headers $header| ConvertFrom-Json
    $envID = "0"
    foreach ($envInfo in $Environment) {
        if ($envName -eq $envInfo.Name) {
            $envID = $envInfo.Id
        }
    }
    return $envID
}

function Find-ReleaseVersion ([string]$url, $header, $releaseID) {
    $Release = Invoke-WebRequest -Uri "$url/api/releases/$releaseID" -Headers $header| ConvertFrom-Json
    Return $release.Version
}


$Applicationid = Find-ProjectID $OctopusURL $OctoPusWRHeader $projectName
$Environmentid = Find-EnvironmentID $OctopusURL $OctoPusWRHeader $EnvironmentName
if (($Applicationid -ne "0") -and ($Environmentid -ne "0")) {
    $dashboard = Invoke-WebRequest -Uri "$OctopusURL/api/dashboard" -Headers $OctoPusWRHeader| ConvertFrom-Json
    foreach($item in $dashboard.Items) {
        if (($item.ProjectID -eq $Applicationid) -and ($Environmentid -eq $item.EnvironmentID)) {
            $version = Find-ReleaseVersion $OctopusURL $OctoPusWRHeader $item.ReleaseId
            write-output $version
            $result.output = "*$projectName* `n $EnvironmentName : $version"
            $result.success = $true
        }
    }
}
else {
    $result.output = "Invalid project environment name."
    $result.success = $false
}

return $result | ConvertTo-Json