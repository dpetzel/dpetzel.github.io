---
categories: [Windows]
date: 2012-06-11
draft: false
tags: [Windows, WinRM]
title: Debugging WinRM
type: post
---
Some notes on my first attempts at doing details debugging and troubleshooting of WinRM
<!--more-->


Useful Articles

* http://www.windowsitpro.com/blog/powershell-with-a-purpose-blog-36/scripting-languages/troubleshooting-winrm-and-powershell-remoting-part-1-137458
* http://www.windowsitpro.com/blog/powershell-with-a-purpose-blog-36/scripting-languages/tools-for-troubleshooting-powershell-remoting-and-winrm-part-2-137463
* http://msdn.microsoft.com/en-us/library/windows/desktop/aa384372(v=vs.85).aspx

Enable Tracing:
```powershell
Set-ExecutionPolicy Unrestricted
Import-Module PSDiagnostics
Enable-PsWsmanCombinedTrace
```

Now run what command is giving grief
Once that command produces your error, disable the trace:
```powershell
Disable-PsWsmanCombinedTrace
```

Output the Log entries to a text file:
```powershell
get-winevent -logname Microsoft-Windows-WinRM/Operational | fl >> C:\winrm_log.txt
get-winevent -path $pshome\traces\pstrace.etl -oldest | fl >> C:\winrm2_log.txt
```

Review the log and hopefully find some answers

