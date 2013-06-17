gvimt.bat
Written by Geoff Wood (geoffrey.wood at_symbol thomsonreuters.com)
gw 13/9/12 - Created
gw 25/9/12 - Updated to raise Vim to foreground, removes awk and grep dependency, adds path option to specify vim location
gw 9/10/12 - Goes to normal mode first to make sure commands execute and don't just go into the file. Waits a bit when starting vim.  Clears the command from the command line afterwards.
gw 9/5/13 adds tv and ts modes to open groups on new tab
gw 10/5/13 added tabsplit_wait_s to fix problem where opening many files would end up on more than one tab
gw 17/6/13 only look at tasks for this user session when checking if vim is already running

gvimt.bat is a script for Windows to open new files in gvim in new tabs, splits or vertical splits.  It starts gvim if it is not running already.

Call it from SendTo menu, from Context menu entries or from the command line.

It uses the tasklist command (which exists from Windows XP, but not in Windows 2000) when checking if gvim is already running.  On Windows 2000 you'll need to have an instance of gvim running already.

It creates gvimt.tmp while it is running, if it crashes or goes wrong for some reason, delete this file.

Install instructions:
=====================
Create directory C:\Batch Files\ and extract the package there. (If you want another directory, change "set batch_path=" at the start of gvimt.bat, and modify gvim.reg accordingly.)

If you do not have the tasklist command (e.g. using Windows 2000), edit the batch file and change "set already_ran" to "=true" at the start of gvimt.bat.

If your gvim typically takes longer than a second to start up, change "set vim_startup_time_ms" to be more milliseconds.

If you find tv and ts commands open files on more than one tab, change "set tabsplit_wait_s" to be more seconds.

If gvim.exe is not in your path, edit gvimt.bat and change "set vim_path=" at the start.  Paths should end with \ and be quoted, e.g. 

    set vim_path="c:\program files\vim\vim73\"

Optionally run the gvimt.reg file to create Context Menu entries.

Optionally, create shortcuts in your SendTo directory with these targets:

"c:\batch files\gvimt.bat" t 
"c:\batch files\gvimt.bat" v
"c:\batch files\gvimt.bat" s
"c:\batch files\gvimt.bat" tv
"c:\batch files\gvimt.bat" ts

Name these three shortcuts something like "Edit with Vim Tab", "Edit with Vim VSplit", "Edit with Vim Split", "Edit with Vim VSplit Tab", and "Edit with Vim Split Tab"

Your SendTo menu directory location depends on which version of Windows you are using.  Under XP it is probably c:\documents and settings\username\SendTo.

Why use this instead of simpler methods?
========================================
There are simpler ways to call gvim directly passing file names to new tabs.  There is the --remote-tab parameter, for example.  Some methods are discussed here: http://vim.wikia.com/wiki/Launch_files_in_new_tabs_under_Windows

There are some problems doing this with many files from the Windows context menu:
- There is no --remote-split parameter so a different approach is needed for opening files in a new split window.  --remote-send can be used to send an arbitary command for this, but unlike --remote-tab it will not open a new instance of gvim if one doesn't already exist.
- If you select multiple files and use the Windows context menu, each file gets its own invocation of the command.  gvim does not handle several simultaneous --remote-tab commands well.
- The SendTo menu does pass all the selected files to one command, but it is an extra click on the right menu to get there, so it is nice to use the Context menu.
