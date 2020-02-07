:: ----------------------------------------------------------------------------------------------------
:: Copyright 2020 Iotacist <iotacist@gmail.com>
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
::
:: ----------------------------------------------------- ::
::  ######                      #     #                  ::
::  #     #   ##   #####   ##   ##   ##   ##   # #####   ::
::  #     #  #  #    #    #  #  # # # #  #  #  # #    #  ::
::  #     # #    #   #   #    # #  #  # #    # # #    #  ::
::  #     # ######   #   ###### #     # ###### # #    #  ::
::  #     # #    #   #   #    # #     # #    # # #    #  ::
::  ######  #    #   #   #    # #     # #    # # #####   ::
:: ----------------------------------------------------------------------------------------------------
:: DataMaid is an alternative to CCleaner and other cleaning tools.
:: This removes temporary data collected by Windows, Internet Explorer, Edge, Firefox and Chrome.
::
:: Script Usage:
::  ¬ Interactive Mode:
::     - Right click DataMaid.bat and select Run As Administrator.
::     - Follow the on-screen instructions and select the mode you wish to use. 
::  ¬ Automated Mode:
::     ¬ Commands:
::        ¬ User
::           - Description:
::               Cleans the executing users temporary locations. 
::           - Command:
::               DataMaid.bat 1
::        ¬ System
::           - Description:
::               Cleans the OS temporary locations. 
::           - Command:
::               DataMaid.bat 2
::        ¬ Terminal Server
::           - Description:
::               Cleans the users temporary locations, loops through each account located in C:\Users.
::           - Command:
::               DataMaid.bat 3
::        ¬ Exit
::           - Description:
::               Terminates the script immediately.
::           - Command:
::               DataMaid.bat 4
:: ----------------------------------------------------------------------------------------------------
@ECHO OFF
TITLE DataMaid
SETLOCAL EnableExtensions DisabledDelayedExpansion

:: 0 = [ Unsupported Version ]
:: 1 = [ XP / Server 2003 / Vista / Server 2008 ]
:: 2 = [ 7 / Server 2008 R2]
:: 3 = [ 8 / Server 2012 / Windows 8.1 / Server 2012 R2 / 10 / Server 2016]
SET WIN_GEN=0

:: 0 = [ CLI Mode ]
:: 1 = [ GUI Mode ]
SET WIN_MODE=0

:: ----------------------------------------------------------------------------------------------------
:: Init Method:
:: ------------
:: This method determines the version of Windows currently installed on the machine.
:: The terminal will be terminated if it has been executed on a unsupported operating system.
:: This method also checks the passed parameters, it will execute in automated mode if it detects
:: a valid parameter.
::
::                                                         --------------------------------------------
::                                                         Operating system               Version      
::                                                         --------------------------------------------
::                                                         Windows 10                      10.0        
::                                                         Windows Server 2016             10.0        
::                                                         Windows 8.1                     6.3         
::                                                         Windows Server 2012 R2          6.3         
::                                                         Windows 8                       6.2         
::                                                         Windows Server 2012             6.2         
::                                                         Windows Server 2008 R2          6.1         
::                                                         Windows 7                       6.1         
::                                                         Windows Server 2008             6.0         
::                                                         Windows Vista                   6.0         
:: ----------------------------------------------------------------------------------------------------
:Init
FOR /f "tokens=4-5 delims=. " %%i IN ('ver') DO SET VER=%%i.%%j
if [%VER%] == [10.0] SET WIN_GEN=3
IF [%VER%] == [6.3] SET WIN_GEN=3
IF [%VER%] == [6.2] SET WIN_GEN=3
IF [%VER%] == [6.1] SET WIN_GEN=2
IF [%VER%] == [6.0] SET WIN_GEN=1
IF "%WIN_GEN%" == [0] ( CALL :Error 1 "Unsupported version of Windows detected!" )
:: Checks passed parameters.
IF "%1"=="1" GOTO UserClean
IF "%1"=="2" GOTO SysClean
IF "%1"=="3" GOTO TermClean
IF "%1"=="4" GOTO Exit
:: No passed parameters, continue to interactive mode.
GOTO MainMenu

:MainMenu
IF [%WIN_MODE%] == [0] SET WIN_MODE=1
CLS
COLOR 02
ECHO ::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=::
ECHO ::        ######                          #     #                            ::
ECHO ::        #     #    ##    #####    ##    ##   ##    ##    #  #####          ::
ECHO ::        #     #   #  #     #     #  #   # # # #   #  #   #  #    #         ::
ECHO ::        #     #  #    #    #    #    #  #  #  #  #    #  #  #    #         ::
ECHO ::        #     #  ######    #    ######  #     #  ######  #  #    #         ::
ECHO ::        #     #  #    #    #    #    #  #     #  #    #  #  #    #         ::
ECHO ::        ######   #    #    #    #    #  #     #  #    #  #  #####          ::
ECHO ::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=::
ECHO :: 1). User                                         ::          Version: 1.5 ::
ECHO :: 2). System (Administrator Required)              ::                       ::
ECHO :: 3). Terminal Server (Administrator Required)     ::     Build: 08/08/2019 ::
ECHO :: 4). Exit                                         :: Author: Thomas Liddle ::
ECHO ::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=::
SET /P opt= :: 
IF "%opt%"=="1" GOTO UserClean
IF "%opt%"=="2" GOTO SysClean
IF "%opt%"=="3" GOTO TermClean
IF "%opt%"=="4" GOTO Exit
CALL :Error 0 "Invalid menu input detected, please choose option 1-4."

:UserClean
CLS
COLOR 06
CALL :ProfileClean %USERPROFILE%
IF [%WIN_MODE%] == [1] (
	PAUSEn
	GOTO MainMenu
) ELSE (
	EXIT
)
GOTO MainMenu

:SysClean
CLS
COLOR 06
:: [ XP / Server 2003 / Vista / Server 2008 ]
IF [%WIN_GEN%] == [1] (
	CALL :DelContents "%SYSTEMDRIVE%\Temp"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\Downloaded Installations"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\Downloaded Program Files"
	:: CentraStage Agent
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\Downloads"
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\AEMAgent\DataLog"
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\AEMAgent\DataLog\Archives"
	:: Windows Small Business Server
	CALL :DelContents "%SYSTEMDRIVE%\Program Files\Windows Small Business Server\Logs\MonitoringServiceLogs"
)
:: [ 7 / Server 2008 R2]
IF [%WIN_GEN%] == [2] (
	CALL :DelContents "%SYSTEMDRIVE%\Temp"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\Temp"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\Prefetch"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\System32\dllcache"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\Downloaded Program Files"
	:: CentraStage Agent
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\Downloads"
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\AEMAgent\DataLog"
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\AEMAgent\DataLog\Archives"
	:: Windows Small Business Server
	CALL :DelContents "%SYSTEMDRIVE%\Program Files\Windows Small Business Server\Logs\MonitoringServiceLogs"
)
:: [ 8 / Server 2012 / Windows 8.1 / Server 2012 R2 / 10 / Server 2016]
IF [%WIN_GEN%] == [3] (
	CALL :DelContents "%SYSTEMDRIVE%\Temp"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\Temp"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\Prefetch"
	CALL :DelContents "%SYSTEMDRIVE%\Windows\System32\dllcache"
	:: CentraStage Agent
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\Downloads"
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\AEMAgent\DataLog"
	CALL :DelContents "%SYSTEMDRIVE%\ProgramData\CentraStage\AEMAgent\DataLog\Archives"
	:: Windows Small Business Server
	CALL :DelContents "%SYSTEMDRIVE%\Program Files\Windows Small Business Server\Logs\MonitoringServiceLogs"
)
IF [%WIN_MODE%] == [1] (
	PAUSE
	GOTO MainMenu
) ELSE (
	EXIT
)
GOTO MainMenu

:TermClean
COLOR 06
CLS
FOR /d %%P IN ("%SYSTEMDRIVE%\Users\*") DO (
	CALL :ProfileClean %%P
	ECHO %%P
)
IF [%WIN_MODE%] == [1] (
	PAUSE
	GOTO MainMenu
) ELSE (
	EXIT
)
GOTO MainMenu

:ProfileClean [path]
:: [ XP / Server 2003 / Vista / Server 2008 ]
IF [%WIN_GEN%] == [1] (
	:: AppData Temp
	CALL :DelContents "%~1\AppData\Local\Temp"
	CALL :DelContents "%~1\AppData\LocalLow\Temp"
	:: Internet Explorer
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\Temporary Internet Files"
	CALL :DelContents "%~1\AppData\Local\Downloaded"
	:: Opera
	CALL :DelContents "%~1\AppData\Local\Opera Software\Opera Stable\Cache"
	:: Google Chrome
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Cache"
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Local Storage"
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Media Cache"
	:: Mozilla Firefox
	CALL :DelFirefoxContents "%~1\AppData\Local\Mozilla\Firefox\Profiles"
)
:: [ 7 / Server 2008 R2]
IF [%WIN_GEN%] == [2] (
	:: AppData Temp
	CALL :DelContents "%~1\AppData\Local\Temp"
	CALL :DelContents "%~1\AppData\LocalLow\Temp"
	:: Internet Explorer
	CALL :DelContents "%~1\AppData\Local\Microsoft\Internet Explorer\IECompatData"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\WebCache"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\History"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\Temporary Internet Files"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Feeds Cache"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Internet Explorer\DOMStore"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\History\History.IE5"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\History\Low\History.IE5"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.IE5"
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\Temporary Internet Files\Low\Content.IE5"
	CALL :DelContents "%~1\AppData\Local\Temp\Low\Cookies"
	CALL :DelContents "%~1\AppData\Local\Temp\Low\History\History.IE5"
	CALL :DelContents "%~1\AppData\Local\Temp\Low\Temporary Internet Files\Content.IE5"
	CALL :DelContents "%~1\AppData\LocalLow\Microsoft\Internet Explorer\DOMStore"
	CALL :DelContents "%~1\AppData\Roaming\Microsoft\Windows\DNTException"
	CALL :DelContents "%~1\AppData\Roaming\Microsoft\Windows\DNTException\Low"
	CALL :DelContents "%~1\AppData\Roaming\Microsoft\Windows\IECompatUACache"
	CALL :DelContents "%~1\AppData\Roaming\Microsoft\Windows\IECompatUACache\Low"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Internet Explorer\UserData"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Internet Explorer\UserData\Low"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Windows\Cookies"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Windows\Cookies\Low"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Windows\IECompatCache"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Windows\IECompatCache\Low"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Windows\IETldCache"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Windows\IETldCache\Low"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Windows\PrivacIE"
	CALL :DelContents "%~1\AppData\AppData\Roaming\Microsoft\Windows\PrivacIE\Low"
	:: Microsoft Edge
	CALL :DelContents "%~1\AppData\Local\MicrosoftEdge\User\Default"
	:: Opera
	CALL :DelContents "%~1\AppData\Local\Opera Software\Opera Stable\Cache"
	:: Google Chrome
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Cache"
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Local Storage"
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Media Cache"
	:: Mozilla Firefox
	CALL :DelFirefoxContents "%~1\AppData\Local\Mozilla\Firefox\Profiles"
)
:: [ 8 / Server 2012 / Windows 8.1 / Server 2012 R2 / 10 / Server 2016]
IF [%WIN_GEN%] == [3] (
	:: AppData Temp
	CALL :DelContents "%~1\AppData\Local\Temp"
	CALL :DelContents "%~1\AppData\LocalLow\Temp"
	:: Internet Explorer
	CALL :DelContents "%~1\AppData\Local\Microsoft\Windows\INetCache"
	:: Microsoft Edge
	CALL :DelContents "%~1\AppData\Local\MicrosoftEdge\User\Default"
	:: Opera
	CALL :DelContents "%~1\AppData\Local\Opera Software\Opera Stable\Cache"
	:: Google Chrome
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Cache"
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Local Storage"
	CALL :DelContents "%~1\AppData\Local\Google\Chrome\User Data\Default\Media Cache"
	:: Mozilla Firefox
	CALL :DelFirefoxContents "%~1\AppData\Local\Mozilla\Firefox\Profiles"
)
GOTO :EOF

:: ----------------------------------------------------------------------------------------------------
:: DelFirefoxContents Method:
:: --------------------------
:: This method loops through each profile listed in the Mozilla Firefox folder specified.
::
:: It then deletes the temporary data locations listed below for each Firefox profile found.
:: 1). C:\Users\<username>\AppData\Local\Mozilla\Firefox\Profiles\<firefox.profile>\cache2\entries
:: 2). C:\Users\<username>\AppData\Local\Mozilla\Firefox\Profiles\<firefox.profile>\cache2\doomed
:: 3). C:\Users\<username>\AppData\Local\Mozilla\Firefox\Profiles\<firefox.profile>\cache2\entries
:: 4). C:\Users\<username>\AppData\Local\Mozilla\Firefox\Profiles\<firefox.profile>\jumpListCache
:: 5). C:\Users\<username>\AppData\Local\Mozilla\Firefox\Profiles\<firefox.profile>\OfflineCache
:: 6). C:\Users\<username>\AppData\Local\Mozilla\Firefox\Profiles\<firefox.profile>\thumbnails
::
:: Example:
:: CALL :DelFirefoxContents "C:\Users\<username>\AppData\Local\Mozilla\Firefox\Profiles"
:: ----------------------------------------------------------------------------------------------------
:DelFirefoxContents [path]
FOR /f "delims=" %%D IN ('DIR %~1 /b') DO (
	CALL :DelContents "%~1\%%D\cache2\entries"
	CALL :DelContents "%~1\%%D\cache2\doomed"
	CALL :DelContents "%~1\%%D\cache2\entries"
	CALL :DelContents "%~1\%%D\jumpListCache"
	CALL :DelContents "%~1\%%D\OfflineCache"
	CALL :DelContents "%~1\%%D\thumbnails"
)
GOTO :EOF

:: ----------------------------------------------------------------------------------------------------
:: DelContents Method:
:: -------------------
:: This method performes safe checks before deleting the contents of the specified folder.
::
:: The following checks are performed, data will only be deleted if all of these checks are successful.
:: 1). Folder path supplied not empty.
:: 2). Folder path supplied exists.
:: 3). Folder path supplied contains data.
::
:: Example:
:: CALL :DelContents "C:\Windows\Temp"
:: ----------------------------------------------------------------------------------------------------
:DelContents [path]
:: Check folder path not empty.
IF NOT "%~1" == "" (
	:: Check folder path exists.
	IF EXIST "%~1" (
		:: Perform 'dir /b' on the folder path and split the output.
		FOR /f "usebackq tokens=*" %%G IN ('DIR %~1 /b') DO (
			:: Ensure folder contains data.
			IF /i "%%G" NEQ "" (
				:: Delete folder contents using wildcard and print results to CMD window.
				DEL /s /f /q "%~1"\*.*
			)
		)
	)
)
GOTO :EOF

:Error [eof] [message]
CLS
COLOR 04
ECHO ::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-::
ECHO :: #######                                  ### ::
ECHO :: #        #####   #####    ####   #####   ### ::
ECHO :: #        #    #  #    #  #    #  #    #  ### ::
ECHO :: #####    #    #  #    #  #    #  #    #   #  ::
ECHO :: #        #####   #####   #    #  #####       ::
ECHO :: #        #   #   #   #   #    #  #   #   ### ::
ECHO :: #######  #    #  #    #   ####   #    #  ### ::
ECHO ::=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-::
ECHO.
ECHO %~2
ECHO.
IF [%~1] == [1] (
	ECHO Please press any key to exit the script...
	PAUSE>NUL
	GOTO Exit
)
ECHO Please press any key to return to the main menu...
PAUSE>NUL
GOTO MainMenu

:Exit
EXIT
