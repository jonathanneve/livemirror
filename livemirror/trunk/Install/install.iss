; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "LiveMirror"
#define MyAppVersion "1.2.0 p1"
#define MyAppPublisher "Microtec Communications"
#define MyAppURL "http://www.copycat.fr"
#define MyAppExeName "LiveMirrorMgr.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{BBFC71D7-E12F-4206-9799-41C56BA604F1}
AppName={#MyAppName}
#IfDef Trial
AppVersion={#MyAppVersion} Evaluation
#else
AppVersion={#MyAppVersion}
#endif
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName=LiveMirror
OutputBaseFilename={#SetupName}_{#MyAppVersion}
Compression=lzma
SolidCompression=true
DisableDirPage=false
DisableProgramGroupPage=true

[Languages]
Name: english; MessagesFile: compiler:Default.isl
Name: french; MessagesFile: compiler:Languages\French.isl

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

Source: ..\Manager\Win32\{#Config}\LiveMirrorMgr.exe; DestDir: {app}\Manager
Source: ..\Manager\Win32\{#Config}\LiveMirrorCpl.cpl; DestDir: {sys}
Source: ..\Manager\locale\FR\LC_MESSAGES\default.mo; DestDir: {app}\Manager\locale\FR\LC_MESSAGES
Source: ..\Manager\locale\FR\LC_MESSAGES\default.po; DestDir: {app}\Manager\locale\FR\LC_MESSAGES

Source: ..\Misc\Win32\{#Config}\LiveMirrorUninstaller.exe; DestDir: {app}\Misc
Source: ..\Misc\locale\FR\LC_MESSAGES\default.mo; DestDir: {app}\Misc\locale\FR\LC_MESSAGES
Source: ..\Misc\locale\FR\LC_MESSAGES\default.po; DestDir: {app}\Misc\locale\FR\LC_MESSAGES

Source: ..\Guardian\locale\FR\LC_MESSAGES\default.mo; DestDir: {app}\Guardian\locale\FR\LC_MESSAGES
Source: ..\Guardian\locale\FR\LC_MESSAGES\default.po; DestDir: {app}\Guardian\locale\FR\LC_MESSAGES
Source: ..\Guardian\Win32\{#Config}\LiveMirrorGuardian.exe; DestDir: {app}\Guardian

Source: ..\Service\Win32\{#Config}\LiveMirrorSrv.exe; DestDir: {app}\Service
Source: ..\Service\locale\FR\LC_MESSAGES\default.mo; DestDir: {app}\Service\locale\FR\LC_MESSAGES
Source: ..\Service\locale\FR\LC_MESSAGES\default.po; DestDir: {app}\Service\locale\FR\LC_MESSAGES

; Common language file goes in each directory
Source: ..\common\locale\FR\LC_MESSAGES\common.po; DestDir: {app}\Manager\locale\FR\LC_MESSAGES
Source: ..\common\locale\FR\LC_MESSAGES\common.mo; DestDir: {app}\Manager\locale\FR\LC_MESSAGES
Source: ..\common\locale\FR\LC_MESSAGES\common.po; DestDir: {app}\Misc\locale\FR\LC_MESSAGES
Source: ..\common\locale\FR\LC_MESSAGES\common.mo; DestDir: {app}\Misc\locale\FR\LC_MESSAGES
Source: ..\common\locale\FR\LC_MESSAGES\common.po; DestDir: {app}\Guardian\locale\FR\LC_MESSAGES
Source: ..\common\locale\FR\LC_MESSAGES\common.mo; DestDir: {app}\Guardian\locale\FR\LC_MESSAGES
Source: ..\common\locale\FR\LC_MESSAGES\common.po; DestDir: {app}\Service\locale\FR\LC_MESSAGES
Source: ..\common\locale\FR\LC_MESSAGES\common.mo; DestDir: {app}\Service\locale\FR\LC_MESSAGES

[Icons]
Name: {group}\{#MyAppName}; Filename: {app}\Manager\{#MyAppExeName}

[Run]
Filename: {app}\Manager\{#MyAppExeName}; Description: {cm:RunLMMgr}; Flags: nowait postinstall skipifsilent
Filename: {app}\Guardian\LiveMirrorGuardian.exe; Parameters: /INSTALL /SILENT

[Dirs]
Name: {app}\Configs
[Registry]
Root: HKLM; Subkey: Software\Microtec\LiveMirror; ValueType: string; ValueName: InstallPath; ValueData: {app}; Flags: createvalueifdoesntexist uninsdeletekey
[UninstallRun]
Filename: sc; Parameters: stop LiveMirror; Flags: nowait
Filename: {app}\Guardian\LiveMirrorGuardian.exe; Parameters: /UNINSTALL /SILENT
Filename: {app}\Misc\LiveMirrorUninstaller.exe

[CustomMessages]
english.RunLMMgr=Run LiveMirror Manager
french.RunLMMgr=Ouvrir l'Administrateur LiveMirror
