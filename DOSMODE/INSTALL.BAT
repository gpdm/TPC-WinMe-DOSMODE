@ECHO OFF

ECHO COPYING FILES ...

copy %WINDIR%\COMMAND.COM
IF NOT ERRORLEVEL 0 GOTO FAIL
copy %WINDIR%\SYSTEM\REGENV32.EXE
IF NOT ERRORLEVEL 0 GOTO FAIL

ECHO APPLYING PATCHES ...

REM REGENV32: REDIRECT CONFIG.SYS / AUTOEXEC.BAT rewrites to .WIN files
REM to leave the original startup files untouched
GSAR -o -s:x43:x4F:x4E:x46:x49:x47:x2E:x53:x59:x53 -r:x43:x4F:x4E:x46:x49:x47:x2E:x57:x49:x4E regenv32.exe
GSAR -o -s:x41:x55:x54:x4F:x45:x58:x45:x43:x2E:x42:x41:x54 -r:x41:x55:x54:x4F:x45:x58:x45:x43:x2E:x57:x49:x4E regenv32.exe

REM COMMAND.COM: Real Mode mode
GSAR -o -s:x75:x10:xB8:x0E -r:xEB:x10:xB8:x0E command.com
GSAR -o -s:x03:x00:x75:x0B:x8B -r:x03:x00:xEB:x0B:x8B command.com
GSAR -o -s:x12:x8B:x16:x08 -r:x44:x8B:x16:x08 command.com

REM COMMAND.COM: Show hidden files in subdirs
GSAR -o -s:xD4:xB9:x10:x00:xB4 -r:xD4:xB9:x16:x00:xB4 command.com
GSAR -o -s:xFC:xB9:x10:x00:xB4 -r:xFC:xB9:x16:x00:xB4 command.com

ECHO INJECTING PATCHED FILES TO INF INSTALLER ...
move.exe /Y COMMAND.COM COMMAND.CO_
move.exe /Y REGENV32.EXE REGENV32.EX_

ECHO STARTING INF INSTALLER ...
RUNDLL32.EXE ADVPACK.DLL,LaunchINFSection DOSMODE.INF,DefaultInstall


EXIT


:FAIL
ECHO FAILED ON PREPARATION, ABORTING.
EXIT
