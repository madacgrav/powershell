Param (
    [string]$changeset,
    [string]$droplocation,
    [string]$ApplicationConfigFilePath
)

$octocmd = "C:\!IT\\octo.exe"
$outputdir = "\\centralstore\"
$octserver = "http:///"
$octkey = "API-"
$version = $changeset.Replace("C","")
$version = "1.0." + $version

if ($ApplicationConfigFilePath.ToLower() -like "*hotfix*") {$version = $version + "-hotfix"}

[XML]$appConfig = Get-Content $ApplicationConfigFilePath

foreach ($app in $appConfig.BuildProjectDeploy.Application) {
   $drop = $droplocation + $app.Source
   $arglist = "pack --id=" + $app.Name + " --version=" + $version + " --outfolder=" + $outputdir + " --basepath=" + $drop
   $p = Start-Process $octocmd -ArgumentList $arglist -wait -NoNewWindow -PassThru
   $p.HasExited
   $p.ExitCode 
   
   if ($p.ExitCode -eq 0) {
        $packagename = $outputdir + $app.Name + "." + $version + ".nupkg"
        $arglist = "push --package=" + $packagename + " --replace-existing --server=" + $octserver + " --apikey=" + $octkey
        $z = Start-Process $octocmd -ArgumentList $arglist -wait -NoNewWindow -PassThru
        $z.HasExited
        $z.ExitCode
   } 
   else {write-verbose ("Package creation failed with the following error " + $p.ExitCode) }
 
}





