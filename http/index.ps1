import-module "$PSScriptRoot\runner.psm1"

# TODO Refactor
$currentSession = "customer-first"
$inputfiles = @("C:\dev\toyapps\DelmeTest\DelmeTest2\bin\Debug\DelmeTest2.dll")

#------------------------------------------------------------

if ("IsRunning" -eq (Get-TestSession $currentSession $HOMEDIRECTORY))
{
    $status = "Status: <a href=`"$currentSession.ps1`">Running</a>"
}
else
{
    $status = @"
        <form class=`"inline`" method=`"POST`" action=`"./$currentSession.ps1`"><input type=`"submit`" name=`"failed-only`" value=`"Re-run failed tests`" /></form>
        <form class=`"inline`" method=`"POST`" action=`"./$currentSession.ps1`"><input type=submit value=`"Rerun all tests in current session`"></form>
"@
}

$results = Get-TestSessionResult $currentSession $HOMEDIRECTORY | Group-Object -Property Result -NoElement
If ($results.Count -ne 0)
{
    $results | ForEach-Object { $TotalCount = 0 } { $TotalCount += $_.Count }
}
else
{
    $TotalCount = ( (Get-TestCases $currentSession $HOMEDIRECTORY $inputfiles) | Measure-Object ).Count
}

$body = @"
<div>
<h1>NUnit Server</h1>
<p class="subtitle">$((Get-Item $HOMEDIRECTORY).FullName)\$currentSession.ps1</p>
<p>Current session #15:
    <!--
    Inconclusive
    Skipped
    Passed
    Failed
    -->
    <a href="/$currentSession.ps1">$TotalCount</a> Test Cases =
    $(($results | % {
        "
        <a href=`"/$currentSession.ps1`">$($_.Count)</a> $($_.Name)
        "
    } )  -join "+" )
</p>
<p>
$status
</p>
<p><form action="./new-session.ps1"><input type="submit" value="Start new session" /></form></p>
<div>
    <h2>History</h2>
    <table>
        <tr>
        <th>Session</th>
        <th>Date</th>
        <th>Total</th>
        <th>Pass</th>
        <th>Fail</th>
        <th>Ignored</th>
        </tr>
    </table>
</div>
</div>
"@

$template = Get-Content $HOMEDIRECTORY\index.htm
$ExecutionContext.InvokeCommand.ExpandString($template)