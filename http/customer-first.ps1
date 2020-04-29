Import-Module "$PSScriptRoot\runner.psm1"

$currentSession = "customer-first"
$testList = "C:\dev\oss\nunit\bin\Release\net46\nunit.framework.tests.dll","C:\dev\oss\nunit\bin\Release\net46\slow-nunit-tests.dll"

$logfile = "$HOMEDIRECTORY\$currentSession.log"
$method = $Context.Request.HttpMethod

If ((Test-Path $logfile) -and ($method -eq 'GET'))
{
    "<pre>"
    Get-Content $logfile -raw
    "</pre><meta http-equiv=`"refresh`" content=`"10`"><script>window.scrollTo(0,document.body.scrollHeight);</script>"
}
ElseIf ((Test-Path "$logfile.old") -and ($method -eq 'GET'))
{
    "<pre>"
    Get-Content "$logfile.old" -raw
    "</pre><meta http-equiv=`"refresh`" content=`"10`"><script>window.scrollTo(0,document.body.scrollHeight);</script>"
}
elseif (-not (Test-Path $logfile) -and ($method -eq 'POST'))
{
    Start-TestSession $currentSession $HomeDirectory $testlist
    $Context.Response.Redirect("./$currentSession.ps1")
    $Context.Response.Close()
}
elseif (-not (Test-Path $logfile) -and ($method -eq 'GET'))
{
    "Not found $logfile<br /> <a href=/>Home</a>"
}
else # ((Test-Path $logfile) -and ($method -eq 'POST'))
{
    "Cannot start $method another test run because $logfile is present"
}