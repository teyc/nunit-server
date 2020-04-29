import-module "$PSScriptRoot\runner.psm1"

$currentSession = "customer-first"

if ("IsRunning" -eq (Get-TestSession $currentSession))
{
    $status = "Status: <a href=`"$currentSession.ps1`">Running</a>"
}
else
{
    $status = @"
        <form class=`"inline`" action=`"./$currentSession.ps1`"><input type=`"submit`" name=`"failed-only`" value=`"Re-run failed tests`" /></form>
        <form class=`"inline`" method=`"POST`" action=`"./$currentSession.ps1`"><input type=submit value=`"Rerun all tests in current session`"></form>
"@
}

$body = @"
<div>
<h1>NUnit Server</h1>
<p class="subtitle">$((Get-Item $HomeDirectory\$currentSession).FullName)</p>
<p>Current session #15: <a href="/$currentSession.ps1">107 tests</a> = 101 passed + 3 ignored + 3 failed</p>
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