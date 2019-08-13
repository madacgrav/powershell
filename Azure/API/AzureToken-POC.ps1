#region variables
$ClientID       = "**app id**" #ApplicationID
$ClientSecret   = "** SPN key**"  #key from Application
$tennantid      = "*** azure ad tenant id***"
$SubscriptionId = '***sub id***'
$resourcegroupname = '**** resource group name****'
$AutomationAccountName = '****automation account****'
$RunbookName = '**runbook name***'
$APIVersion = '2015-10-31'
#endregion

#region Get Access Token
$TokenEndpoint = "https://login.windows.net/****tenantid******/oauth2/token"
$ARMResource = "https://management.core.windows.net/";

$Body = @{
        'resource'= $ARMResource
        'client_id' = $ClientID
        'grant_type' = 'client_credentials'
        'client_secret' = $ClientSecret
}

$params = @{
    ContentType = 'application/x-www-form-urlencoded'
    Headers = @{'accept'='application/json'}
    Body = $Body
    Method = 'Post'
    URI = $TokenEndpoint
}

$token = Invoke-RestMethod @params
#endregion


# #region get Runbooks
# $Uri = 'https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Automation/automationAccounts/{2}/runbooks?api-version={3}' -f $SubscriptionId, $resourcegroupname, $AutomationAccountName, $APIVersion
# $params = @{
#   ContentType = 'application/x-www-form-urlencoded'
#   Headers     = @{
#     'authorization' = "Bearer $($token.Access_Token)"
#   }
#   Method      = 'Get'
#   URI         = $Uri
# }
# $test = Invoke-RestMethod @params -OutVariable Runbooks
# $crap = $test | ConvertTo-Json
# $crap.value[0]
# #endregion

#region Start Runbook
$Uri = 'https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Automation/automationAccounts/{2}/jobs/{3}?api-version={4}' -f $SubscriptionId, $resourcegroupname, $AutomationAccountName, $((New-Guid).guid), $APIVersion
$body = @{
  'properties' = @{
    'runbook'  = @{
      'name' = $RunbookName
    }
    'parameters' = @{
      'tasktype' = 'list'
    }
    'runon' = 'hybridworkername'
  }
  'tags'     = @{}
} | ConvertTo-Json

$params = @{
  ContentType = 'application/json'
  Headers     = @{
    'authorization' = "Bearer $($token.Access_Token)"
  }
  Method      = 'Put'
  URI         = $Uri
  Body        = $body
}

Invoke-RestMethod @params -OutVariable Runbook
$Runbook.properties
