; Windows installer (Inno Setup 6): Start menu entry, optional desktop icon and uninstaller.
; Input: dist\Foco, the folder made by windeployqt. Version from the FOCO_VERSION variable.
#define Version GetEnv("FOCO_VERSION")

[Setup]
AppId={{E3B9F419-05A7-474C-9DD0-A347CDC8DEC5}
AppName=Foco
AppVersion={#Version}
AppPublisher=Andrés García
AppPublisherURL=https://github.com/andresgarcia0313/foco-pomodoro
DefaultDirName={autopf}\Foco
DefaultGroupName=Foco
DisableProgramGroupPage=yes
; Per-user install by default: no administrator rights needed.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=foco.ico
UninstallDisplayIcon={app}\foco.ico
LicenseFile=..\..\LICENSE
OutputDir=..\..\dist
OutputBaseFilename=Foco-{#Version}-windows-x64-instalador
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; Flags: unchecked

[Files]
Source: "..\..\dist\Foco\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "foco.ico"; DestDir: "{app}"

[Icons]
Name: "{group}\Foco"; Filename: "{app}\foco.exe"; IconFilename: "{app}\foco.ico"
Name: "{autodesktop}\Foco"; Filename: "{app}\foco.exe"; IconFilename: "{app}\foco.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\foco.exe"; Description: "{cm:LaunchProgram,Foco}"; Flags: nowait postinstall skipifsilent
