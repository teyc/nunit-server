# nunit-server

a tiny webserver in front of nunit

## Getting started

1. Run Powershell as Administrator, execute the following and then close the window

        netsh http add urlacl http://+:8081/ user=Everyone listen=yes

2. Update runner.psm1 with path to nunit3-console.exe

        $RUNNER = "C:\Users\Chui\.nuget\packages\nunit.consolerunner\3.11.1\tools\nunit3-console.exe"

3. Update customer-first.ps1 `inputfiles` with DLLs

        $inputfiles = @("C:\dev\toyapps\DelmeTest\DelmeTest2\bin\Debug\DelmeTest2.dll")

4. Start a Powershell window as a regular user. Note: the _child_ powershell
   instance is required to support CTRL+C break

        PS C:\temp\nunit-server > Set-ExecutionPolicy Unrestricted -Scope CurrentUser

        PS C:\temp\nunit-server > powershell.exe .\POSHServer-Standalone.ps1

## Overview

nunit3-console will pipe output to a log file. When the log file is
present, our webserver will not start another test session.

When nunit3-console terminates, the log file is moved to `.log.old`
so that you can review the results later.

File extensions:

    .log      logs from currently executing session
    .log.old  logs from previous session
    .txt      list of test cases
    .xml      test results
    2.xml     test results from 2nd pass (failed tests)
