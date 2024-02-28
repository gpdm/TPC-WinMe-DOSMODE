# File Sources for Windows Me MS-DOS Mode

* `IO.SYS` is from the Windows Millennium NETTOOLS, included on the Windows Me CD. (Contained within `TOOLS\NETTOOLS\FAC\CBS.DTA`; a CAB file.)

    This file contains the XMS driver, IFSHLP driver and Windows boot logo, and does not require any additional lines added to CONFIG.SYS or AUTOEXEC.BAT to start Windows. It also contains the Windows Millennium Boot Menu accessible by holding CTRL on startup, allowing the user to choose Normal, Safe Mode, Command Line Only, etc.
    
    Decompressed with Rudolph Loew's IO8DCOMP, and the "Now preparing to start your new computer..." string displayed on startup has been replaced with "Starting Windows Millennium Edition...".


* `COMMAND.COM` is not bundled, but locally patched

    An unmodified version of `COMMAND.COM` could be taken from the Windows Millennium NETTOOLS on the Windows Me CD instead, requiring no patching.
    This version of `COMMAND.COM` is contained within `TOOLS\NETTOOLS\FAC\LTOOLS.DTA`; a CAB file.

    The reason for not bundling it is to apply the patches to the locally installed `COMMAND.COM` instead, retaining `COMMAND.COM` in the localized language.

    The patches are applied in [INSTALL.BAT](https://github.com/gpdm/TPC-WinMe-DOSMODE/blob/main/DOSMODE/INSTALL.BAT#L17-L24)

* `REGENV32.EXE` is not bundled either, for the same reason as mentioned for `COMMAND.COM`

    `REGENV32` reads Windows environment variables from the registry and overwrites the contents of `AUTOEXEC.BAT` and `CONFIG.SYS` on each restart.
    These patches instead have `REGENV32` write to `AUTOEXEC.WIN` and `CONFIG.WIN`, leaving the contents of `AUTOEXEC.BAT` and `CONFIG.SYS` intact so the user can make alterations or add additional lines as needed.

    The patches are applied in [INSTALL.BAT](https://github.com/gpdm/TPC-WinMe-DOSMODE/blob/main/DOSMODE/INSTALL.BAT#L12-L15)

* `SYS.COM` is from Windows Millennium Developer Release 1 (Build 2332).

    This file is unmodified. Its behaviour is otherwise the same as SYS.COM in Windows 98 Second Edition, however the version information in the DR1 build is already updated for MS-DOS 8.0, so no patches are required to overcome the "Incorrect DOS version" error.
    
    `SYS.COM` allows the user to copy MS-DOS system files to a specified drive letter and make it bootable. The `SYS` command included in the retail release of Windows Millennium disables this feature and instructs the user to create a Startup Disk in Control Panel > Add/Remove Programs instead. Replacing `SYS.COM` restores its original functionality.


* `WIN.COM` is from Windows 98 Second Edition.

    At present, this file is unmodified. The Windows Me version may still be usable however, so this is not finalised.
    
    In Windows Me, Microsoft removed the undocumented switches needed to exit MS-DOS mode and back to Windows - specifically the /WX switch. When booting into MS-DOS mode with a custom `AUTOEXEC` and `CONFIG`, the existing `AUTOEXEC.BAT` and `CONFIG.SYS` are moved out of the way into `AUTOEXEC.WOS` and `CONFIG.WOS` respectively. The /WX switch moves the temporary `.WOS` files back into `.BAT` and `.SYS`, and restarts into Windows. Without this switch, the computer just continues to reboot into MS-DOS mode with each restart, or the computer just hangs when "exit" or "win" is typed.
    
    It may be possible to re-add these undocumented switches back into Windows Me's `WIN.COM`.


* `WINOA386.MOD` is from either Windows 98 Second Edition or Windows Millennium Developer Release 1 (Build 2332).

    The Millennium DR1 file is an unmodified, direct replacement. It seems to work fine, however it's still being tested. (It appears to be extremely similar to the 98 version though, even when comparing their contents in hex side-by-side.)
    
    The Windows 98 file is patched, and requires the replacement of two bytes - Offset 0x2CE2 replace 0A with 5A, and Offset 0x2D4C replace 00 with 5A - to clear a mismatched Windows version error. However it also seems to work fine.
    
    "WINOA386.MOD` provides a console for MS-DOS within the 32 bit Windows environment and gives access to the command line disk operating system commands which MS-DOS offers.
    The `WINOA386` file included in the retail release of Windows Millennium returns warnings that Real Mode MS-DOS is no longer supported, and prevents restarting into MS-DOS mode when called from the Shut Down window. Using the DR1 or 98 version of this file removes this limitation.


* `PIFMGR.DLL` is from either Windows 98 Second Edition or Windows Millennium Developer Release 1 (Build 2332).

    Both the Millennium DR1 and Windows 98 files are unmodified, direct drop-in replacements. Both contain different code internally, but appear to otherwise behave the same.
    
    This file handles the use of .PIF files, MS-DOS application properties (from Right Click > Properties), the creation of temporary AUTOEXEC.BAT and CONFIG.SYS files when restarting into MS-DOS mode, and specifies the commands that should be issued to `WIN.COM` when leaving MS-DOS mode.
    
    The `PIFMGR.DLL` included in the retail release of Windows Millennium returns an error when restarting into MS-DOS mode that the AUTOEXEC.APP and CONFIG.APP temporary files were unable to be created in the C:\ directory due to permissions (existing files marked read-only) or lack of free space. Using the DR1 or 98 version of this file resolves this error.

​

There is one more optional file:

* `IO8EMMOK.SYS` by [Dr. Pu-Feng Du](https://github.com/pufengdu/IO8EMMOK)

    The `IO.SYS` built-in XMS driver replaces `HIMEM.SYS` in MS-DOS 8.0. I'm sketchy on the details, but essentially unlike earlier versions of DOS, to maximise free conventional memory MS-DOS 8.0 and the XMS driver itself are always loaded above 1MB. This High Memory Area is addressable with the A20 line enabled (Gate-A20 ON). However most applications expect the XMS driver to be somewhere within the first 1MB, and turn Gate A20 OFF before calling into the XMS driver. However because MS-DOS 8.0 and the XMS driver are above 1MB, turning Gate A20 OFF makes the driver (and all of DOS, in fact) inaccessible in memory, and so the system hangs.
    
    Worst of all, the XMS driver itself is responsible for turning Gate A20 on and off as needed, so if it isn't accessible, then it can't switch the gate on as needed when DOS requires it either.
    
    The most notable example of this is `EMM386.EXE`, the EMS driver included with MS-DOS that some applications depend on. Attempting to load `EMM386` in `CONFIG.SYS` immediately halts the system and prevents Windows or MS-DOS from booting.
    
    `IO8EMMOK` places a small wrapper in the addressable area under 1MB. When a call to the XMS driver is made, it enables Gate A20, forwards the call, and disables Gate A20 again. This allows the XMS driver to remain accessible and in control of the gate, allowing DOS to continue running, and EMM386 to function as normal.
    
    This allows applications and games that require EMS memory to run within the Real Mode DOS environment, and not just within the Windows protected mode environment. (In theory, this even allows Windows 3.11 to be run in 386 Enhanced Mode, in tandem with Windows Millennium on MS-DOS 8.)

​

Then there's the alterations made within the Windows registry:

    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\WinOldApp\NoRealMode is deleted. This allows the "Restart in MS-DOS mode" option to appear in the Shut Down dialog.
    
    The HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\MS-DOSOptions\HIMEM key is deleted. Because IO.SYS calls on its own integrated XMS driver, loading HIMEM in CONFIG.SYS is no longer required. Removing this key prevents the "DEVICE=C:\WINDOWS\Himem.Sys" line from being added by default when right clicking an MS-DOS program, and selecting Properties > Program > Advanced > MS-DOS Mode > Specify a new MS-DOS configuration.
    
    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\MS-DOSOptions\IO8EMMOK\ has been added to call WINDOWS\IO8EMMOK.SYS before EMM386.EXE by default when creating a custom AUTOEXEC and CONFIG in the MS-DOS application properties window.
