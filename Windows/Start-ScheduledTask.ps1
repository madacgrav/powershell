Param(
  [string]$jobname,
  [string]$jobtype,
  [string]$jobserver
)

$username = "<user>"
$secpassword = ConvertTo-SecureString "******password*****" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($username, $secpassword)
$connection = New-CimSession -ComputerName $jobserver -Credential $mycreds -Authentication Negotiate
$chatresult = @{}
if ($connection) {
    if ($jobtype -eq "run") {
        $results = Get-ScheduledTask -CimSession $connection | Where-Object { $_.Taskname -eq $jobname}
        if ($results) {
            $task = Start-ScheduledTask -CimSession $connection -Taskname $jobname
            write-verbose "Task *$($jobname)* - started."
            $chatresult.output = "Task *$($jobname)* - started."
            $chatresult.success = $true
        }
        else {
            write-verbose "Task Not Found"
            $chatresult.output = "Task *$($jobname)* - NOT FOUND."
            $chatresult.success = $false
        }
    }
    elseif ($jobtype -eq "list") {
        $tasks = Get-ScheduledTask -CimSession $connection -TaskPath "\"
        $tasklist = ""
        foreach ($task in $tasks) {
            $tasklist = $tasklist + "- *$($task.TaskName)* -" 
        }
        write-verbose $tasklist
        if ($tasklist -eq "") {
            $chatresult.output = "No tasks found"
            $chatresult.success = $false
        }
        else {
            $chatresult.output = $tasklist
            $chatresult.success = $true
        }
    }
    else {
        write-verbose "Request for information not understood.  Please retype command"
        $chatresult.output = "Bad request."
        $chatresult.success = $false
    }
}
else {
    $chatresult.output = "Invalid server name."
    $chatresult.success = $false  
}
return $chatresult | ConvertTo-Json