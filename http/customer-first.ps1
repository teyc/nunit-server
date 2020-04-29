Import-Module "$PSScriptRoot\runner.psm1"

$currentSession = "customer-first"
$inputfiles = @("C:\dev\toyapps\DelmeTest\DelmeTest2\bin\Debug\DelmeTest2.dll")

$logfile = "$HOMEDIRECTORY\$currentSession.log"
$method = $Context.Request.HttpMethod
$failedOnly = [bool] $poshPost."failed-only"

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
    "</pre><script>window.scrollTo(0,document.body.scrollHeight);</script>"
    "<div style='color: red'>Test Completed</div>"
    "<a href=/>Home</a>"
}
elseif (-not (Test-Path $logfile) -and ($method -eq 'POST'))
{
    If ($failedOnly)
    {
        Start-TestSession $currentSession $HomeDirectory $inputfiles -FailedOnly $failedOnly -RetryFailed
    }
    else
    {
        Start-TestSession $currentSession $HomeDirectory $inputfiles -RetryFailed
    }
    $Context.Response.Redirect("./$currentSession.ps1")
}
elseif (-not (Test-Path $logfile) -and ($method -eq 'GET'))
{
    "Not found $logfile<br /> <a href=/>Home</a>"
}
else # ((Test-Path $logfile) -and ($method -eq 'POST'))
{
    "Cannot start $method another test run because $logfile is present"
}