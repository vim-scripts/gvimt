@echo off

REM Script for Windows to open new files in gvim in new tabs, splits or vertical splits
REM See gvimt_README.txt for details
REM Creates gvimt.tmp while it is running, if it crashes for some reason, delete this file

REM Geoff Wood (geoffrey.wood@thomsonreuters.com)

REM gw 13/9/12 created
REM gw 17/9/12 awk script brings vim to the foreground
REM gw 25/9/12 uses findstr instead of grep, and direct call instead of via awk, and optional vim path added
REM gw 27/9/12 expand to full path so can call from command line for a file in the local directory
REM            also fixed typo recently introduced where vsplits were just acting as splits
REM gw 8/10/12 get into normal mode first, fixes problem where command appears in file text in insert mode
REM gw 9/5/13 adds tv and ts modes to open groups on new tab
REM gw 10/5/13 added tabsplit_wait_s to fix problem where opening many files would end up on more than one tab
REM gw 17/6/13 only look at tasks for this user session when checking if vim is already running
REM gw 2/12/13 Prefer to use cmd-line vim to list remote servers
REM            If it does have to use tasklist, handle case where sessionname is not populated
REM              (crudely, by quoting the parameter so findstr doesn't just bomb out.  Will still fail if
REM              there are two sessions and this is the wrong one.  But the error will be more noticable.)
REM gw 11/3/14 Stop using short paths to be Windows 7 compatible

setlocal ENABLEDELAYEDEXPANSION

REM If gvim.exe is not in your path you can add the path here,
REM make sure it ends in a \ character and is quoted if necessary
REM Set the path to command-line vim as well
REM e.g. set gvim_path="c:\program files\vim\vim73\"
set gvim_path=
set vim_path=

set batch_path="c:\batch files\"
set already_ran=false
set vim_startup_time_ms=1000
set tabsplit_wait_s=3

if %1_==_ goto usage
if /i %1 NEQ t if /i %1 NEQ v if /i %1 NEQ s if /i %1 NEQ tv if /i %1 NEQ ts goto usage

set task=%1

goto check_already_running

:usage
@echo usage: gvimt [t^|v^|s^|tv^|ts] file [file2 ...]
@echo t - open each file in new tab
@echo v - open each file in new vertical split
@echo s - echo each file in new split
@echo tv - open new tab with files vertically split
@echo ts - open new tab with files split
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

shift

REM If another instance ran, it made sure
REM gvim was running
REM Otherwise do it now
if %already_ran%==false (

    REM tasklist sometimes fails in odd circumstances, sessionname is not populated
    REM So prefer to use vim to check instead.  This only shows vims local to this session
    %vim_path%vim --version > nul
    if !errorlevel!==0 (
        %vim_path%vim --serverlist | findstr GVIM
    ) else (
        tasklist | findstr "%SESSIONNAME%.*" | findstr gvim.exe > nul
    )
    if not !errorlevel!==0 (
        start %gvim_path%gvim.exe -c "let g:gvimt_time_this=localtime()" %1
		set already_ran=true

        REM sometimes we miss the first file out possibly if vim hasn't finished starting?
        REM give it enough time
        ping -w %vim_startup_time_ms% -n 1 1.2.3.4
        shift
    )
)

:next_file

REM if %1_==_ goto raise_to_foreground

if %1_==_ goto end
if /i %task% EQU t start %gvim_path%gvim.exe --remote-send "<Esc>:tablast | tabe %~f1<CR>:call foreground()<CR><CR>"
if /i %task% EQU v start %gvim_path%gvim.exe --remote-send "<Esc>:vsplit %~f1<CR>:call foreground()<CR><CR>"
if /i %task% EQU s start %gvim_path%gvim.exe --remote-send "<Esc>:split %~f1<CR>:call foreground()<CR><CR>"

if /i %task% EQU tv start %gvim_path% gvim.exe --remote-send "<Esc>:if exists("""g:gvimt_time_this""") | let g:gvimt_time_last=g:gvimt_time_this | else | let g:gvimt_time_last=0 | endif | let g:gvimt_time_this=localtime() | if g:gvimt_time_this > g:gvimt_time_last + %tabsplit_wait_s% | tablast | tabe %~f1 | else | vsplit %~f1 | endif | call foreground()<CR><CR>"

if /i %task% EQU ts start %gvim_path% gvim.exe --remote-send "<Esc>:if exists("""g:gvimt_time_this""") | let g:gvimt_time_last=g:gvimt_time_this | else | let g:gvimt_time_last=0 | endif | let g:gvimt_time_this=localtime() | if g:gvimt_time_this > g:gvimt_time_last + %tabsplit_wait_s% | tablast | tabe %~f1 | else | split %~f1 | endif | call foreground()<CR><CR>"

shift

goto next_file

REM This routine sort of works but its very complicated and it throws errors sometimes
REM Also it still doesn't always raise the VIM to the front
REM
REM :raise_to_foreground
REM REM have to go through all this to find out what the remote server is called, then
REM REM call remote_foreground.  It still sometimes doesn't work (if called from Windows
REM REM Explorer) but at least the taskbar flashes now.
REM if %already_ran%==false (
REM 	%gvim_path%gvim.exe --remote-send ":let gvimt_server = [v:servername]<CR>:call writefile(gvimt_server,'%short_batch_path%\gvimt_server.tmp')<CR><CR>"
REM 	set /p gvimt_server=< %short_batch_path%\gvimt_server.tmp
REM 	set gvimt_server='!gvimt_server!'
REM ) else (
REM 	set gvimt_server='GVIM'
REM )
REM start %gvim_path%gvim.exe -c "call remote_foreground(%gvimt_server%)" -c "q"
REM del %short_batch_path%\gvimt_server.tmp

:end
if exist %batch_path%\gvimt.tmp del %batch_path%\gvimt.tmp
endlocal
