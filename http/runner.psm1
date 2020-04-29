$RUNNER = "C:\Users\Chui\.nuget\packages\nunit.consolerunner\3.11.1\tools\nunit3-console.exe"

function Start-TestSession($sessionName, $HomeDirectory, $testlist, [switch] $failedOnly = $false, [switch] $retryFailed)
{

    $result =  "$HOMEDIRECTORY\$sessionName.xml"
    $logfile = "$HOMEDIRECTORY\$sessionName.log"

    Start-Job -ScriptBlock {
        Param ($runner, $testlist, $logfile, $result)
        & "$runner" @testList "--result=$result"  >> $logfile

        Start-Sleep -Seconds 5

        Move-Item $logfile "$logfile.old" -Force
    } -ArgumentList $RUNNER,$testList,$logfile,$result

    Get-TestCases $sessionName $homedirectory $testlist

    Start-Sleep 5
}

function Get-TestCases($sessionName, $HomeDirectory, $TestList)
{
    $explore = "$HOMEDIRECTORY\$sessionName.txt"

    If (Test-Path $explore)
    {
        # Scan assembly again if .dll is newer
        $lastWriteTime = (Get-Item $explore).LastWriteTime
        $scanAssembly = (
            $Testlist |
                ? { (Test-Path $_) -and ((Get-Item $_).LastWriteTime -gt $lastWriteTime) } |
                measure ).Count -gt 0
    }
    else
    {
        $scanAssembly = $true
    }

    If ($scanAssembly)
    {
        $count = 0
        & "$RUNNER" @testList "--explore" |
            Where-Object {
                # Skip 2 blank lines
                if (-not [bool] $_ ) { $count++ }
                Return ($count -gt 2 -and [bool] $_)
            } > $explore
        }
    }

    Get-Content $explore
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

function Get-TestSessionResult($sessionName, $homedirectory)
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