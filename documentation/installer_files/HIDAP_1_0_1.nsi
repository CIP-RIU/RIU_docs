
;--------------------------------
;Include Modern UI
  !include "MUI2.nsh"
  ;include "LogicLib.nsh"
  ;!include "nsis\EnvVarUpdate.nsh"
  ;!include "nsis\SpaceCheck.nsh"


;--------------------------------
;General

  ;Properly display all languages (Installer will not work on Windows 95, 98 or ME!)
  Unicode true
!define APPNAME "HIDAP"
!define COMPANYNAME "International Potato Center (CIP)"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD "19-09-2016"

  ;Name and file
  ;Name "HIDAP v1.0"
  !define MUI_ICON "hidapicon.ico"
  !define MUI_UNICON "hidapicon.ico"
  !define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
  Name "${COMPANYNAME} - ${APPNAME}"

  !define /date MyTIMESTAMP "%Y-%m-%d-%H-%M-%S"
  OutFile "HIDAP_v1.0-${MyTIMESTAMP}.exe"

  ;Default installation folder
  InstallDir "$LOCALAPPDATA\HIDAP"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\HIDAP" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
;Interface Settings



;ABOUTURL "http://www.cipotato.org"


  !define MUI_ABORTWARNING

  ;Show all languages, despite user's codepage
  !define MUI_LANGDLL_ALLLANGUAGES

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\HIDAP" 
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;--------------------------------
;Pages
!define WELCOME_TEXT "HiDAP is a Highly Interactive Data Analysis Platform originally meant to support clonal crop breeders at the International Potato Center. It is part of a continuous institutional effort to improve data collection, data quality, data analysis and open access publication. The recent iteration simultaneously also represents efforts to unify best practices from experiences in breeding data management of over 10 years, specifically with DataCollector and CloneSelector for potato and sweetpotato breeding, to address new demands for open access publishing and continue to improve integration with both corporate and community databases (such as biomart and sweetpotatobase) and platforms such as the Global Trial Data Management System (GTDMS) at CIP. One of the main new characteristics of the new software development platform established over the last two years is the web-based interface."

  !define MUI_WELCOMEPAGE_TITLE "'HIDAP' installer will guide you through the setup. Please close all other programs!"
  !define MUI_WELCOMEPAGE_TITLE_3LINES
  !define MUI_WELCOMEPAGE_TEXT "${WELCOME_TEXT}"
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English" ;first language is the default language

;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections

 !define HIDAP_HOME $INSTDIR


;--------------------------------
;Installer Sections

Section "R 3.3.1" SecR
  SetOutPath "$INSTDIR"
  FILE 'R-3.3.1-win.exe'
  ExecWait 'R-3.3.1-win.exe'
  DELETE 'R-3.3.1-win.exe'
SectionEnd




Section "R tools 3.3" SecRtools
  SetOutPath "$INSTDIR"
  FILE 'HD2_Rtools33.exe'
  ExecWait 'HD2_Rtools33.exe'
  DELETE 'HD2_Rtools33.exe'
SectionEnd

Section "Pandoc 1.17.2" SecPandoc
  SetOutPath "$INSTDIR"
  FILE 'pandoc-1.17.2-windows.msi'
  ExecWait  '"msiexec" /i "pandoc-1.17.2-windows.msi"'
  DELETE 'pandoc-1.17.2-windows.msi'
SectionEnd




Section "HIDAP package Section" SecHidap
 SetOutPath "$INSTDIR"
  DetailPrint 'Preparing libraries ...'

  FILE /r "res"
  FILE /r "xdata"

  DELETE "$INSTDIR\.Rprofile"
  ;DELETE "$INSTDIR\zip.exe"
  ;DELETE "$INSTDIR\hidapicon.ico"

  DetailPrint 'Installing libraries ...'
  ReadRegStr $0 HKLM "Software\R-core\R\3.3.1" "InstallPath"
  ExecWait '$0\bin\Rscript.exe $INSTDIR\res\zip\install.R'
SectionEnd  
 
Section "HIDAP setup Section" SecHidapSetup
  SetOutPath "$INSTDIR"
  DetailPrint 'Cleaning up ...'
  RMDir /r $INSTDIR\res\zip

  DELETE "$INSTDIR\.Rprofile"
  DELETE "$INSTDIR\zip.exe"
  DELETE "$INSTDIR\hidapicon.ico"
  
  FILE '.Rprofile'
  FILE zip.exe
  FILE "hidapicon.ico"
  
  ;${EnvVarUpdate} $0 "HIDAP_HOME" "A" "HKLM" "$INSTDIR"


  ;Store installation folder
  WriteRegStr HKCU "Software\HIDAP" "Install_Dir" $INSTDIR

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HIDAP" "DisplayName" "HIDAP"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HIDAP" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HIDAP" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\HIDAP" "NoRepair" 1
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd



; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts" SecShortCuts

  !define env_hklm 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
   !define env_hkcu 'HKCU "Environment"'
 
  !include "winmessages.nsh"

  ;WriteRegExpandStr ${env_hklm} HIDAP_HOME "$INSTDIR"
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  ReadRegStr $0 HKLM "Software\R-core\R\3.3.1" "InstallPath"
  ;DetailPrint "R is installed at: $0"
  CreateShortcut "$INSTDIR\R-HIDAP.lnk" "$0\bin\x64\Rterm.exe" "" "hidapicon.ico" 0 SW_SHOWMINIMIZED CONTROL|SHIFT|H "${COMPANYNAME} - ${APPNAME}"

  CreateDirectory "$SMPROGRAMS\HIDAP"
  CreateShortcut "$SMPROGRAMS\HIDAP\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "hidapicon.ico" 0
  CreateShortcut "$SMPROGRAMS\HIDAP\HIDAP.lnk" "$INSTDIR\R-HIDAP.lnk" "" "hidapicon.ico" 2 SW_SHOWMINIMIZED  CONTROL|SHIFT|H "${COMPANYNAME} - ${APPNAME}"

  ;ExecShell "" "$INSTDIR\R.exe"
  
SectionEnd


;--------------------------------
;Installer Functions

Function .onInit

  !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

;--------------------------------
;Descriptions

  ;USE A LANGUAGE STRING IF YOU WANT YOUR DESCRIPTIONS TO BE LANGAUGE SPECIFIC

  ;Assign descriptions to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecR} "Basic platform. Necessary."
    ;!insertmacro MUI_DESCRIPTION_TEXT ${SecRtools} "Basic platform. Necessary."
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPandoc} "Basic platform. Necessary."
    !insertmacro MUI_DESCRIPTION_TEXT ${SecHIDAP} "HIDAP R libraries. Necessary."
	!insertmacro MUI_DESCRIPTION_TEXT ${SecHIDAPSetup} "HIDAP setup. Necessary."
    !insertmacro MUI_DESCRIPTION_TEXT ${SecShortCuts} "Optional shortcuts."
  !insertmacro MUI_FUNCTION_DESCRIPTION_END


 
;--------------------------------
;Uninstaller Section

Section "uninstall"

  ;ADD YOUR OWN FILES HERE...
  ;Push HIDAP_HOME
  ;Call un.DeleteEnvStr
  DeleteRegValue ${env_hklm} HIDAP_HOME
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  Delete "$INSTDIR\Uninstall.exe"
  Delete "$INSTDIR\.Rprofile"
  Delete "$INSTDIR\zip.exe"
  Delete "$INSTDIR\hidapicon.ico"
  
  RMDir /r "$INSTDIR"

  DeleteRegKey /ifempty HKCU "Software\HIDAP"

SectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit

  ;!insertmacro MUI_UNGETLANGUAGE
  
FunctionEnd