@echo off

REM Script for Windows to open new files in gvim in new tabs, splits or vertical splits
REM See gvimt_README.txt for details
REM Creates gvimt.tmp while it is running, if it crashes for some reason, delete this file

REM Geoff Wood (geoffrey.wood@thomsonreuters.com)

REM gw 13/9/12 created
REM gw 17/9/12 awk script brings vim to the foreground

setlocal ENABLEDELAYEDEXPANSION

set batch_path="c:\batch files"
set already_ran=false

if %1_==_ goto usage
if /i %1 NEQ t if /i %1 NEQ v if /i %1 NEQ s goto usage

goto check_already_running

:usage
@echo usage: gvimt [t^|v^|s] file [file2 ...]
@echo t - open each file in new tab
@echo v - open each file in new vertical split
@echo s - echo each file in new split
goto end

REM If run from right-click menu on multiple files
REM there may be many instances running
REM We want the first to do the job of making sure gvim
REM is running, the rest to wait for this
:check_already_running
set already_running=false
if exist %batch_path%\gvimt.tmp (
    set already_running=true
    set already_ran=true
    ping -w 100 -n 1 1.2.3.4
)
if %already_running%==true goto :check_already_running

REM While we have this file other instances will wait
REM for us to complete
echo %2 > %batch_path%\gvimt.tmp

set task=%1
shift

REM If another instance ran, it made sure
REM gvim was running
REM Otherwise do it now
if %already_ran%==false (
    tasklist | grep -q gvim.exe
    if not !errorlevel!==0 (
        start gvim.exe %1
        shift
    )
)

:next_file
if %1_==_ goto end
REM run with awk script to avoid issues with \ quoting
awk -f %batch_path%\gvimt.awk %task% %1
shift
goto next_file

:end
if exist %batch_path%\gvimt.tmp del %batch_path%\gvimt.tmp
endlocal
