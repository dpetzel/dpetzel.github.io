---
layout: post
title: "Modifying your PoshGit Prompt"
category:
tags:
---
{% include JB/setup %}
If your using [Github for Windows](https://windows.github.com/), there is a
good chance you might be using the Powershell Git Shell. If your like me you
may want to customize how that prompt looks. Turns out this is not nearly as
trivial as it would initially seem.

If your not familiar with PoshGit, you can read a little more about it on their
[github page](https://github.com/dahlbyk/posh-git/blob/master/readme.md). In
a nutshell, this integration enhances your current Powershell prompt to provide
you with git related information right in your prompt. For anyone that uses
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), it provides similar
functionality to that.

Powershell allows you to override the prompt by configuring a [prompt function](
http://ss64.com/ps/syntax-prompt.html) inside your profile.  So let's pause here..
this *sounds* simple enough, but the reality you're profile is actually loaded
from one of a possible 4 files. Knowing exactly which one to edit is an adventure
on all on its own. That whole debacle is covered in detail at
<http://technet.microsoft.com/en-us/magazine/2008.10.windowspowershell.aspx>
so I'll skip going into details there. We'll leave it at knowing there is fairly
well documented (albeit cumbersome) methods of changing your Powershell prompt.

Enter PoshGit. Since its nothing more than a wrapper around your existing
Powershell, it would seem logical that any shell customizations you may have
already applied would be used and PoshGit would extend upon that. Sad to say
that is not the case... Now to be fair, the README for PoshGit does cover this,
but it takes a fair amount of connecting the dots to know that PoshGit is even
a thing. For me there was a series of research and trial and error that lead me
to learning what PoshGit was, the fact that it was part of Github for Windows,
and ultimately how to hack it to do what I wanted.

I'll skip over the pain and agony I went through getting from A to B. I'll keep it
brief and say no amount of `profile.ps1` hackery will work here.

Instead the key to success lies in `C:\Users\<you>\AppData\Local\GitHub\PoshGit_3874a02de8ce2b7d4908a8c0cb302294358b972c\profile.example.ps1`
(I don't know if that GUID looking number changes between installations).
Despite its name, this file is actually **not** a sample, but is the actual
profile that is loaded by GitHub for Windows when using Powershell as your shell.

Start by creating a function named `global:prompt` (I think just prompt might
also work). Inside that function make all your customizations, and then be sure
to include a call to `Write-VcsStatus`. The `Write-VcsStatus` is the key to
ensuring you continue to get all the git integration that PoshGit supplies.

Here is what my function looks like. In my case I was looking to not have
super long directory structures included in the prompt, and instead just
display the name of the directory I'm currently in. Credit for this goes to
<http://winterdom.com/2008/08/mypowershellprompt> which I used to figure out
how to change the prompt, I adapted for my own tastes.

```powershell
function global:prompt {
  $cdelim = [ConsoleColor]::DarkCyan
  $chost = [ConsoleColor]::Green
  $cloc = [ConsoleColor]::Cyan

  write-host "$([char]0x0A7) " -n -f $cloc
  write-host ' {' -n -f $cdelim
  write-host (split-path (pwd) -Leaf) -n -f $cloc
  write-host '}' -n -f $cdelim

  Write-VcsStatus

  $global:LASTEXITCODE = $realLASTEXITCODE
  return "> "
}
```

If your curious, this makes my shell look something like this (but with colors):

```powershell
Windows PowerShell
Copyright (C) 2009 Microsoft Corporation. All rights reserved.

§  {dpetzel.github.io} [master +1 ~0 -0 !]>
```

At the end of the day, the act of actually making the change wasn't complicated
at all, however figuring out the "what and where" of what to change was a time
consuming process.
