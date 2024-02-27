# DOS Mode for Windows Millenium Edition

This is the the inofficial DOS Mode for Windows Millenium Edition.

This was [sourced from app.box.com](https://app.box.com/s/jfiy8p0m2p2vbvh4zzolznh3lp2yanfe),
and is based ofn the original work of user iMic, who had posted this initially on the [MSFN.org](https://msfn.org/board/topic/184833-full-featured-real-mode-dos-in-windows-millennium/)
and [overclockers.com.au](https://forums.overclockers.com.au/threads/showing-windows-me-some-love.1311910/page-2#post-19360466) forums.

However, to furtherly evolve it, I have taken it to apply some tweaks and improvements as furtherly explained below.


## What's this exactly?

So in iMic's own words, as he had originally described this on the forums:

``
This is Real Mode MS-DOS, running under Windows Millennium. Not just the patches commonly found around the internet, but the real deal. Restart to MS-DOS mode enabled, AUTOEXEC and CONFIG processed on boot, and applications can be instructed to reboot into DOS and back into Windows when they’ve completed.

It achieves this by patching a couple of instructions in COMMAND.COM and REGENV32.EXE, using a specialised IO.SYS from the Windows Millennium CD, and using the MS-DOS application layer (WINOA386.MOD and PIFMGR.DLL) from Millennium Developer Release 1. "Restart in MS-DOS mode" is restored by removing the "NoRealMode" key from HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\WinOldApp in the Windows registry.

So, what currently works?

    "Restart in MS-DOS mode" from the shutdown dialog restarts to a command prompt.
    DOS applications can be configured to restart in MS-DOS mode from the Properties window, and custom AUTOEXEC.BAT and CONFIG.SYS entries can be specified per application.
    Windows XMS driver, integrated into IO.SYS, currently replaces the functionality of HIMEM.SYS. (Attempting to load HIMEM.SYS results in the "An Extended Memory Manager is already installed" error.)
    EMM386 loads and works, both in DOS mode and within Windows, although it currently requires the IO8EMMOK driver (https://github.com/pufengdu/IO8EMMOK) to be loaded first in CONFIG.SYS to make the built-in XMS driver behave more like a standard HIMEM.
    AUTOEXEC.BAT and CONFIG.SYS are processed and loaded at startup.
    Holding CTRL on startup brings up the Windows Millennium Startup menu, and it now includes "Command Prompt Only" in addition to the normal startup options.
    NEW Creating a MS-DOS boot disk by using the SYS command line utility has been re-enabled.


There are still some issues to work on however -

    Selecting "Use current MS-DOS configuration" in an application's MS-DOS mode properties / PIF and using it to restart into MS-DOS mode just shuts down the computer. Selecting "Specify a new MS-DOS configuration" and entering a custom AUTOEXEC and CONFIG works fine. This includes the "Exit to DOS" PIF used when selecting "Restart in MS-DOS mode" from the Start > Shut Down menu, which just shuts down the system if the Exit to DOS PIF doesn't have a custom AUTOEXEC and CONFIG specified.
    When selecting "Specify a new MS-DOS configuration" in properties, a "DEVICE=C:\WINDOWS\Himem.Sys" line is automatically added despite Windows Me being unable to use HIMEM. [FIXED] Required a minor alteration to the registry.
    When you have finished using MS-DOS mode, typing "exit" would normally return to Windows, however this just hangs the system. Resetting the computer and letting Windows start up normally completes the "Windows Millennium is now restarting" sequence. [PARTIAL] Replacing WIN.COM with the Windows 98 SE version allows Windows Millennium to restart from MS-DOS mode. Patching of the Windows Me version may be possible.
    Because resuming from Hibernation is handled partly in IO.SYS, the alterations to this file mean that Hibernation still needs to be tested. Likewise, System Restore needs to be tested to ensure it can still create and restore system snapshots correctly.
    At the moment installation involves dragging files into place and manually editing the registry. In addition, PIFMGR.DLL is protected by Windows and needs to be replaced from within the DOS mode environment (either Command Prompt Only or automated instructions in AUTOEXEC). This can be resolved by writing a Setup INF that moves files into place using Windows' own system file update mechanisms. [PARTIAL] An incomplete version of the Setup INF has been written, and installs successfully. Subject to some minor tweaking.
    Update KB311561 contains an updated IO.SYS with some bug fixes. The IO.SYS used to currently boot into DOS mode does not contain these fixes, so they need to be patched in if possible.


The aim is to resolve as many issues as possible before offering this out to the public for testing, with the hope it can eventually be distributed as part of the Windows Me Bonus Extras Pack 2, and as an optional install on an upcoming maintenance release of the Update CD.
``

## What's different with this release?

This release stays mostly true to the original, except in a few points:

* The INF file was rewritten into an ADVANCED INF ((INF Guide)[https://www.mdgx.com/INF_web/index.htm])
* The INF installer registers install itself to the Windows registry for "uninstallation"
* Proper uninstall functionality is provided and reverts all changes on removal
* A BAT install file was added, which performs pre-install patching
* neither COMMAND.COM nor REGENV32.EXE are bundled are bundled with this release, but the local files are patched instead
* GSAR.EXE is bundled to perform in-place patching
* SYS.COM, WINOA386.MOPD, PIFMR.DLL and WINBOOT.SYS ("IO.SYS") are still bundled
* FORMAT.COM from Windows 98 is now bundled as prepatched copy as well
* see also (File Source)[FILESOURCES.md] for more details on bundled and/or patched files


## Known limitations

* KB311561 is not integrated
* Limitations for booting into MS-DOS mode
* Windows Me's System File Protection (SFP) is causing problems


### KB311561 is not integrated

As noted, the fixes to IO.SYS coming with KB311561 have not been integrated.
Some runtime patching using GSAR is performed from INSTALL.BAT, so it should be possible to apply those patches at runtime.


### Limitations for booting into MS-DOS mode

The original author mentions this limitation, which stays unresolved for the time:

``
 When "Restart in MS-DOS mode" is selected, Windows checks for the presence of "Exit to DOS.pif" in C:\WINDOWS. This PIF can contain absolutely anything - you can instruct it to launch any DOS application, in MS-DOS mode or in an MS-DOS Prompt window, it doesn't matter.

This could also be - for example - a script or application that does the necessary setup for restarting to a command prompt from within Windows, effectively bypassing Windows' own internal mechanisms.

I've created a proof-of-concept "EXITDOS.BAT" that is called from "Exit to DOS.pif". This script performs the following operations -

    Checks for AUTOEXEC.BAT and CONFIG.SYS. If either file is not found, it creates new ones from the AUTOEXEC.WIN and CONFIG.WIN files generated by the patched REGENV32.
    Ensures those AUTOEXEC.BAT and CONFIG.SYS files are not hidden, and are writable (not read-only).
    Checks for AUTOEXEC.APP and CONFIG.APP, and removes them if present. These are generated when returning to Windows from an MS-DOS mode session, and should be automatically removed, but sometimes they can persist. If the .APP files from a previous MS-DOS mode session are not removed before restarting to a new MS-DOS mode session, it can prevent the computer from returning to Windows when EXIT or WIN /WX is typed, until those .APP files are removed.
    Copies the current contents of AUTOEXEC.BAT to AUTOEXEC.WOS. WIN.COM removes the AUTOEXEC.BAT containing our temporary entries and renames AUTOEXEC.WOS back to AUTOEXEC.BAT when the computer restarts from MS-DOS mode.
    Checks if COMMAND.COM is to be launched after restart, or if a different application path is specified as a parameter instead.
    Adds some temporary commands to the end of AUTOEXEC.BAT for the MS-DOS session. (See Below.)
    Issues a command to restart the computer.

When the computer is in MS-DOS mode, typing EXIT or WIN /WX removes the temporary AUTOEXEC.BAT containing the temporary commands we added, and restores the temporary backup version created earlier (AUTOEXEC.WOS) to AUTOEXEC.BAT. This is a documented function of Windows, and actually how applications that restart into MS-DOS mode with "Specify a new MS-DOS configuration" selected are handled - we're just exploiting its abilities for our own purposes.

If only WIN is typed, Windows Millennium will still start up, but will return to an MS-DOS mode when the computer is restarted again. Typing EXIT or WIN /WX is what instructs the computer to re-configure itself and return to a normal startup again.

The temporary commands added to the end of AUTOEXEC.BAT are:

ECHO Type EXIT to return to Windows.

CALL %WINDIR%\COMMAND.COM
%WINDIR%\WIN.COM /WX

Calling COMMAND.COM is what drops the computer to a command prompt instead of immediately launching Windows. When EXIT is typed, the command interpreter closes, and the next line - WIN.COM /WX - is called, setting the computer up for a normal startup and rebooting the system again.

 

What all this means is that "Restart in MS-DOS mode" works. It's not particularly elegant, but there are some ways it could be improved -

    The EXITDOS.BAT file could be rewritten as a dedicated .COM or .EXE executable with the same functionality instead, which would improve performance, and reliability if it isn't calling out to a bunch of extra DOS utilities like XCOPY and ATTRIB.
    "Exit to DOS.pif" could be skipped entirely if the filename were patched to "EXITDOS.COM" (or whatever it would be) in SHELL32.DLL, removing one extra file and bypassing the PIF manager. However this would prevent the user from specifying their own "Exit to DOS.pif" with different functionality if they wished.

On the other hand, this method has an advantage - you can also restart into MS-DOS mode simply by typing "EXITDOS", or restarting into MS-DOS mode and launching a different application by typing "EXITDOS PATH\TO\EXAMPLE\PROGRAM.EXE", either from an MS-DOS Prompt, a Batch File, or the Start > Run dialog.

 

This leaves one feature broken - right clicking a DOS application, selecting Properties > Program > Advanced > MS-DOS mode > "Use current MS-DOS configuration" to launch an application. Fixing this would involve finding out where this function is handled in the OS, and patching it to call out to EXITDOS instead.

Of course patching it here would probably eliminate the need for "Exit to DOS.pif" in Start > Shutdown as well, as it's likely these are hooked to the same or similar functions. I think if this were achieved, most would consider this a satisfactory solution to handling MS-DOS mode in Windows Millennium, since it would contain all the functionality present in Windows 95/98, handled a little differently, but without the need for any compromise. 
``

### Windows Me's System File Protection (SFP) issues

The original author mentioned this:

``The modifications can be installed via a Setup INF, without the need to disable System Restore or System File Protection.``

At least during my tests, I couldn't confirm this statement.
When installing files, in particular `SYS.COM` and `FORMAT.COM`, to `C:\WINDOWS\COMMAND`,
Windows Me's SFP will kick-in and replace them with the factory default files, no matter what.

The only way is to disable SFP via `msconfig`.

The way I handle this in the updated INF installer right now, is to install `SYS.COM` and `FORMAT.COM` to `C:\WINDOWS`.
This directory takes precendence in the `%PATH%` statement, and thus makes `SYS`and `FORMAT` commands working,
restoring the original behaviour.

SFP will not complain about these files existing in `C:\WINDOWS` directory.

However, to properly fix it, I seem to understand from reading some documentation,
that the correct approach should be to

* create a `CATALOG` file from the INF file using the Windows ME SDK/DDK
* sign the `CATALOG` file
* and inject the CATALOG file during the installation

which should update the SFP overall catalog, and allow replacing the `SYS.COM` and `FORMAT.COM` in `C:\WINDOWS\COMMAND`.

This has to still be tried out to confirm if that assumption is correct.


## Missing Features


### Missing "Create System Disk" Option in UI Dialog

The Windows "disk format" dialog does not provide a function to create a system disk.
This functionality can propably be restored as well by borrowing a file from Windows Me Developer Releases
or Windows 98.
 




