echo off

if "%ACT_MULTI_OPNAME%" == "scrub-mount" if "%ACT_MULTI_END%" == "true" if "%ACT_PHASE%" == "post" ( GOTO maskcommand )
if "%ACT_MULTI_OPNAME%" == "mount" if "%ACT_MULTI_END%" == "true" if "%ACT_PHASE%" == "post" ( GOTO maskcommand )

if "%1" == "test" ( GOTO maskcommand )
if "%1" == "" echo If you want to manually run this command add test after the bat file name, like this:    %0 test
exit /B 0

:maskcommand
SQLCMD.EXE -b -i "C:\Program Files\Actifio\scripts\%2"
IF %ERRORLEVEL% EQU 0 (GOTO cleanexit)
exit /B 1

:cleanexit
exit /B 0
