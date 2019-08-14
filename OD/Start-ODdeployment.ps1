Param(
    [string]$ProjectName,
    [string]$EnvironmentName,
    [string]$ReleaseVersion
  )

#Constants
$apiKey = "** API key"
$OctopusURL = "http://)D url"


##PROCESS##
$Header =  @{ "X-Octopus-ApiKey" = $apiKey }
$result = @{}

#Getting Project
Try{
    $Project = Invoke-WebRequest -Uri "$OctopusURL/api/projects/$ProjectName" -Headers $Header -ErrorAction Ignore| ConvertFrom-Json
    Write-Verbose $Project
    $good = $true
    }
Catch{
    $good = $false
   Write-Error $_
    #Throw "Project not found: $ProjectName"
}

if ($good) {
    #Getting environment
    $Environment = Invoke-WebRequest -Uri "$OctopusURL/api/Environments/all" -Headers $Header| ConvertFrom-Json
    $Environment = $Environment | ?{$_.name -eq $EnvironmentName}
    If($Environment.count -eq 0){$good = $false}

    if ($good) {
        If($ReleaseVersion -eq "Latest"){
            $release = ((Invoke-WebRequest "$OctopusURL/api/projects/$($Project.Id)/releases" -Headers $Header).content | ConvertFrom-Json).items | select -First 1
            If($release.count -eq 0){
                $good = $false
                #throw "No releases found for project: $ProjectName"
            }
        }
        else{
            Try{
            $release = (Invoke-WebRequest "$OctopusURL/api/projects/$($Project.Id)/releases/$ReleaseVersion" -Headers $Header).content | ConvertFrom-Json
            }
            Catch{
                $good = $false
                #Write-Error $_    
                #throw "Release not found: $ReleaseVersion"    
            }
        }
        if ($good) {
            #Creating deployment and setting value to the only prompt variable I have on $p.Form.Elements. You're gonna have to do some digging if you have more variables
            $DeploymentBody = @{ 
                        ReleaseID = $release.Id #mandatory
                        EnvironmentID = $Environment.id #mandatory                          
                    } | ConvertTo-Json
                    
            $deploy = Invoke-WebRequest -Uri $OctopusURL/api/deployments -Method Post -Headers $Header -Body $DeploymentBody
            $result.output = "Deployment *$($ProjectName)* - started."
            $result.success = $true
        }
        else {
            $result.output = "Deployment *$($ProjectName)* - failed. Invalid version number"
            $result.success = $false
        }
    }
    else {
      #  write-output "Bad environment"
        $result.output = "Deployment *$($ProjectName)* - failed. Invalid environment name."
        $result.success = $false
    }
}
else {
  #  write-output "Bad project"
    $result.output = "Deployment *$($ProjectName)* - failed. Invalid project/application name."
    $result.success = $false
}

return $result | ConvertTo-Json