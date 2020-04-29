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