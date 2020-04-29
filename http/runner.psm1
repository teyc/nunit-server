$RUNNER = "C:\Users\Chui\.nuget\packages\nunit.consolerunner\3.11.1\tools\nunit3-console.exe"

function Start-TestSession($sessionName, $HOMEDIRECTORY, $inputfiles, [switch] $failedOnly = $false, [switch] $retryFailed = $false) {

    $paths = Get-TestPath $sessionName $HOMEDIRECTORY
    $logfile = $paths.logfile

    $job = Start-Job -Name $sessionName -ScriptBlock {
        Param ($sessionName, $HOMEDIRECTORY, $runner, $inputfiles, $failedOnly, $retryFailed)

        Import-Module "$HOMEDIRECTORY\Runner.psm1"
        $paths = Get-TestPath $sessionName $HOMEDIRECTORY
        $result = $paths.result
        $result2 = $paths.result2
        $logfile = $paths.logfile
        $failedFile = $paths.failedfile

        # Run the full suite
        if (-Not $failedOnly) {

            "======================= RUNNING ALL TESTS ===================" >> $logfile

            & "$runner" @inputfiles "--result=$result"  >> $logfile

            Start-Sleep -Seconds 1 # Let file flush

            $results = Get-TestSessionResult $sessionName $HOMEDIRECTORY
            $results | Format-Table >> $logfile
            $results | Where-Object -Property Result -eq -Value "Failed" | ForEach-Object { $_.Name } > $failedFile

        }

        # Find failed file and run failed
        If ($failedOnly -Or ($retryFailed -and (Get-Item $failedFile).Length -gt 0)) {
            "======================= RUNNING FAILED TESTS ===================" >> $logfile
            "$runner $($inputfiles -Join ' ') --testlist=$failedFile --result=$result2" >> $logfile
            & "$runner" @inputfiles "--testlist=$failedFile" "--result=$result2"  >> $logfile
        }

        Start-Sleep -Seconds 2

        Move-Item $logfile "$logfile.old" -Force

    } -ArgumentList $sessionName, $HOMEDIRECTORY, $RUNNER, $inputfiles, $failedOnly, $retryFailed

    # Get-TestCases $sessionName $HOMEDIRECTORY $inputfiles

    $job >> $logfile
    Start-Sleep 5

}

function Get-TestCases($sessionName, $HOMEDIRECTORY, $inputfiles) {
    $explore = "$HOMEDIRECTORY\$sessionName.txt"

    If (Test-Path $explore) {
        # Scan assembly again if .dll is newer
        $lastWriteTime = (Get-Item $explore).LastWriteTime
        $scanAssembly = (
            $inputfiles |
            Where-Object { (Test-Path $_) -and ((Get-Item $_).LastWriteTime -gt $lastWriteTime) } |
            Measure-Object ).Count -gt 0
    }
    else {
        $scanAssembly = $true
    }

    If ($scanAssembly) {
        $count = 0
        & "$RUNNER" @inputfiles "--explore" |
        Where-Object {
            # Skip 2 blank lines
            if (-not [bool] $_ ) { $count++ }
            Return ($count -gt 2 -and [bool] $_)
        } > $explore
    }

    Get-Content $explore
}

function Get-TestSession($sessionName, $HOMEDIRECTORY) {
    if (Test-Path (Get-TestPath $sessionName $HOMEDIRECTORY).logfile) {
        Return "IsRunning"
    }
    else {
        Return "IsStopped"
    }
}

function Get-TestPath($sessionName, $HOMEDIRECTORY) {
    @{
        result = "$HOMEDIRECTORY\$sessionName.xml"
        result2 = "$HOMEDIRECTORY\$($sessionName)2.xml"
        logfile = "$HOMEDIRECTORY\$sessionName.log"
        failedFile = "$HOMEDIRECTORY\$sessionName.fail"
    }
}
function Get-TestSessionResult($sessionName, $HOMEDIRECTORY) {
    $file = "$HOMEDIRECTORY\$sessionName.xml"
    $logfile = "$HOMEDIRECTORY\$sessionName.log"

    If (Test-Path $file) {

        $xml = [xml] (Get-Content $file -Encoding utf8)

        $xml.SelectNodes("//test-case") |
        ForEach-Object {
            [pscustomobject] @{
                Name     = $_.fullname
                Duration = $_.duration
                Result   = $_.result
                EndTime  = $_."end-time"
            }
        }
    }
    else {
        return @()
    }

}