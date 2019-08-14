Param(
    [string]$emailTo = "a",
    [string]$emailSubject = "Application Updated",
    [string]$emailBody = "Info here"

  )
  

$userid=''
$secpasswd = ConvertTo-SecureString "" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($userid, $secpasswd)
#$creds=Get-Credential $userid
Send-MailMessage `
    -To $emailTo `
    -Subject $emailSubject `
    -Body $emailBody `
    -UseSsl `
    -Port 587 `
    -SmtpServer 'smtp.com' `
    -From $userid `
    -Credential $creds