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