[CmdletBinding()]
Param(
    [string]$tasktype,
    [string]$searchterm,
    [string]$project,
    [string]$env,
    [string]$version,
    [string]$email,
    [string]$slackRoomID = ""
  )

$apiKey = Get-AutomationVariable -Name 'ODapiKey'
$OctopusURL = "http://"
$Header =  @{ "X-Octopus-ApiKey" = $apiKey }

function Get-GroupMembership([string]$username){
        $username = $username.replace("@.com", "")
        $groups = (Get-ADUser $username –Properties MemberOf).MemberOf | % {$_.split(",")[0].replace("CN=","")}
        return $groups
}

function Get-Projects ([string]$search) {
    $list = " "
    Try{
        $Projects = Invoke-WebRequest -Uri "$OctopusURL/api/projects/all" -Headers $Header -ErrorAction Ignore -UseBasicParsing | ConvertFrom-Json
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
        $result = ":white_check_mark: Deployments List ``````" + $list + "``````"
    }
    catch {
        $result = ":sos: Deployment Query Error.  Check with DevOps Admin. " + $_.Exception.Message
    }
    
    return $result
}

function Get-ProjectID ($ProjectName) {
    Try{
        $found = $false
        $Projects = Invoke-WebRequest -Uri "$OctopusURL/api/projects/all" -Headers $Header -ErrorAction Ignore -UseBasicParsing | ConvertFrom-Json
        foreach ($project in $Projects) {
            if ($project.Name -eq $ProjectName) {
                    $result = $project.ID
                    $found = $true
            }
        }
    }
    catch {
        $result = ":sos: Error " + $_.Exception.Message 
    }
    if (!($found)) {
        $result = ":sos: Error project not found"
    }
    return $result
}

function Start-Deployment ($EnvironmentName, $ProjectName, $ReleaseVersion) {

    $projectid = Get-ProjectID $ProjectName

    if ($projectid -contains "Error") {
        $goodProjectCall = $false
        $result = $projectid
    }
    else {
        $goodProjectCall = $true
    }
    
    if ($goodProjectCall) {
        #Getting environment
        try  {
            $Environment = Invoke-WebRequest -Uri "$OctopusURL/api/Environments/all" -Headers $Header -UseBasicParsing | ConvertFrom-Json
            $goodEnvCall = $true
            $Environment = $Environment | where-object{$_.name -eq $EnvironmentName}
            If($Environment.count -eq 0){
                $goodEnvCall = $false
                $result = ":sos: Deployment *$($ProjectName)* - failed. Invalid environment name."
            }
        }
        catch {
            $result = ":sos: Deployment OD Query Error.  Check with #SRE Admin. Error: " + $_.Exception.Message
            $goodEnvCall = $false
        }
        if ($goodEnvCall) {
            If($ReleaseVersion -eq "Latest"){
                try {
                    $release = ((Invoke-WebRequest "$OctopusURL/api/projects/$projectid/releases" -Headers $Header -UseBasicParsing).content | ConvertFrom-Json).items | select -First 1
                    $goodReleaseCall = $true
                    If($release.count -eq 0){
                        $goodReleaseCall = $false
                        $result = ":sos: Deployment *$($ProjectName)* - failed. Invalid version number"
                    }
                }
                catch {
                    $result = ":sos: Error with release version.  Check with #SRE Admin. Error: " + $_.Exception.Message
                }
            }
            else{
                Try{
                    $release = (Invoke-WebRequest "$OctopusURL/api/projects/$projectid/releases/$ReleaseVersion" -Headers $Header -UseBasicParsing ).content | ConvertFrom-Json
                }
                Catch{
                    $goodReleaseCall = $false
                    $result = ":sos: Error with release version.  Check with #SRE Admin. Error: " + $_.Exception.Message
                }
            }
            if ($goodReleaseCall) {
                #Creating deployment and setting value to the only prompt variable I have on $p.Form.Elements. You're gonna have to do some digging if you have more variables
                $DeploymentBody = @{ 
                            ReleaseID = $release.Id #mandatory
                            EnvironmentID = $Environment.id #mandatory                          
                        } | ConvertTo-Json
                
                try {
                    $deploy = Invoke-WebRequest -Uri $OctopusURL/api/deployments -Method Post -Headers $Header -Body $DeploymentBody -UseBasicParsing 
                    $result = ":white_check_mark: Deployment *$($ProjectName)* - started."
                }
                catch {
                    $result = ":sos: Cannot excecute deployment.  Check with #SRE Admin. Error: " + $_.Exception.Message
                }
            }
        }
    }
    
    return $result
}

$dsdeployments_roomid = Get-AutomationVariable -Name ''
$deployments_roomid = Get-AutomationVariable -Name ''
$pythondeployment_roomid = Get-AutomationVariable -Name ''

$roomlist = ($dsdeployments_roomid, $deployments_roomid , $pythondeployment_roomid)
write-output $roomlist
write-output ("Passed room " + $slackRoomID)

write-output "Start OD Commands"
if ($roomlist -contains $slackRoomID)  {
    switch ($tasktype) {
        "list"  {
            write-output "Start Project search"
            $projectlist = Get-Projects $searchterm
            write-output $projectlist
            .\Post-SlackbyChannelID.ps1 -roomID $slackRoomID -slacktext $projectlist -slackuser "BB"
        }
        "deploy" {
            #check if member of the correct AD group
            $ADgroups = Get-GroupMembership -UserName $email
            $allowed = $false
            foreach ($group in $ADgroups) {
                if (($env.tolower() -eq "production") -and ($group -eq "")) {
                    $allowed = $true
                }
                if (($group -eq "") -and ($env.tolower() -ne ""))  {
                    $allowed = $true
                }
            }
            if ($allowed) {
                write-output "Start Deployment"
                $deployment = Start-Deployment $env $project $version
                write-output $deployment
                .\Post-SlackbyChannelID.ps1 -roomID $slackRoomID -slacktext $deployment -slackuser "BB"
            }
            else {
                $slackdeployment = ":middle_finger: Permission to deploy to $env not allowed. Please check with #sre for details. :middle_finger:"
                .\Post-SlackbyChannelID.ps1 -roomID $slackRoomID -slacktext $slackdeployment -slackuser "BB"
            }

        }
        default {
            $slacktext = "No tasktype was given.  Please try command again."
            .\Post-SlackbyChannelID.ps1 -roomID $slackRoomID -slacktext $slacktext -slackuser "BB"
        }
    }
}
else {
    $slacktext = "Invalid Channel.  BB-Deployment commands are only available in #deployments, #dsdeployments, and #pythondeployment channels"
    .\Post-SlackbyChannelID.ps1 -roomID $slackRoomID -slacktext $slacktext -slackuser "BB"
}