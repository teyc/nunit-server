$currentSession = "customer-first"
$runner = "C:\Users\Chui\.nuget\packages\nunit.consolerunner\3.11.1\tools\nunit3-console.exe"
$testList = "C:\dev\oss\nunit\bin\Release\net46\nunit.framework.tests.dll"
$explore = "$HOMEDIRECTORY\$currentSession.txt"
$result =  "$HOMEDIRECTORY\$currentSession.xml"
$logfile = "$HOMEDIRECTORY\$currentSession.log"
$method = $Context.Request.HttpMethod

If ((Test-Path $logfile) -and ($method -eq 'GET'))
{
    "<pre>"
    Get-Content $logfile -raw
    "</pre><script>window.scrollTo(0,document.body.scrollHeight);</script>"
}
elseif (-not (Test-Path $logfile) -and ($method -eq 'POST'))
{

    Start-Job -ScriptBlock {
        Param ($runner, $testlist, $logfile, $result)
        & "$runner" "$testList"  >> $logfile

        Start-Sleep -Seconds 5

        Move-Item $logfile "$logfile.old" -Force
    } -ArgumentList $runner,$testList,$logfile,$result

    & "$runner" "$testList" "--explore" > $explore
    Start-Sleep 5
    # "<script>window.location = '$currentSession.ps1'</script>"
    $Context.Response.Redirect("./$currentSession.ps1")
    $Context.Response.Close()
}
else
{
    "Cannot start $method another test run because $logfile is present"
}
