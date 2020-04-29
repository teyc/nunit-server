$RUNNER = "C:\Users\Chui\.nuget\packages\nunit.consolerunner\3.11.1\tools\nunit3-console.exe"

function Start-TestSession($sessionName, $HomeDirectory, $testlist)
{

    $explore = "$HOMEDIRECTORY\$sessionName.txt"
    $result =  "$HOMEDIRECTORY\$sessionName.xml"
    $logfile = "$HOMEDIRECTORY\$sessionName.log"

    Start-Job -ScriptBlock {
        Param ($runner, $testlist, $logfile, $result)
        & "$runner" "$testList" "--result=$result"  >> $logfile

        Start-Sleep -Seconds 5

        Move-Item $logfile "$logfile.old" -Force
    } -ArgumentList $RUNNER,$testList,$logfile,$result

    & "$RUNNER" "$testList" "--explore" > $explore
    Start-Sleep 5
}

function Get-TestSession($sessionName)
{
    if (Test-Path (Get-TestSessionLogPath $sessionName))
    {
        Return "IsRunning"
    }
    else
    {
        Return "IsStopped"
    }
}

function Get-TestSessionLogPath($sessionName)
{
    "$HomeDirectory\$sessionName.log"
}

function Get-TestSessionResult($homedirectory, $sessionName)
{
    $file = "$HomeDirectory\$sessionName.xml"
    If (Test-Path $file)
    {
        $xml = [xml] (Get-Content $file)

        $xml.SelectNodes("//test-case") |
            ForEach-Object {
                [pscustomobject] @{
                    Name = $_.name
                    Duration = $_.duration
                    Result = $_.result
                    EndTime = $_."end-time"
                }
        }
    }
    else
    {
        return @()
    }

}