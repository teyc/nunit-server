$currentSession = "customer-first"
$runner = "C:\Users\Chui\.nuget\packages\nunit.consolerunner\3.11.1\tools\nunit3-console.exe"
$testList = "C:\dev\oss\nunit\bin\Release\net46\nunit.framework.tests.dll"
$explore = "$HOMEDIRECTORY\$currentSession.txt"
$result =  "$HOMEDIRECTORY\$currentSession.xml"
$logfile = "$HOMEDIRECTORY\$currentSession.log"

# Write-Output "$currentSession $runner $testList $explore $result $logFile"

If ((Test-Path $logfile) -or ($Context.Request.Method -eq 'GET'))
{
    "<pre>"
    Get-Content $logfile -raw
    "</pre><script>window.scrollTo(0,document.body.scrollHeight);</script>"
}
else
{

    Start-Job -ScriptBlock {
        Param ($runner, $testlist, $logfile)
        & "$runner" "$testList" "--result=$result" >> $logfile
        Move-Item $logfile $logfile.".old" -Force
    } -ArgumentList $runner,$testList,$logfile

    #& "$runner" "$testList" "--explore" > $explore
    $Context.Response.Redirect("./Customer-First.ps1")
}