unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, CtlPanel;

type
  TLiveMirrorManager = class(TAppletModule)
    procedure AppletModuleActivate(Sender: TObject; Data: Integer);
  private
  { Déclarations privées }
  protected
  { Déclarations protégées }
  public
  { Déclarations publiques }
  end;

var
  LiveMirrorManager: TLiveMirrorManager;

implementation

uses ShellAPI, Psapi, LMUtils, dialogs;

{$R *.DFM}

type

TFindWindowRec = record
  ModuleToFind: string;
  FoundHWnd: HWND;
end;

function EnumWindowsCallBack(Handle: hWnd; var FindWindowRec: TFindWindowRec): BOOL; stdcall;
const
  C_FileNameLength = 256;
var
  WinFileName: string;
  PID, hProcess: DWORD;
  Len: Byte;
begin
  Result := True;
  SetLength(WinFileName, C_FileNameLength);
  GetWindowThreadProcessId(Handle, PID);
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
  Len := GetModuleFileNameEx(hProcess, 0, PChar(WinFileName), C_FileNameLength);
  if Len > 0 then
  begin
    SetLength(WinFileName, Len);
    if SameText(WinFileName, FindWindowRec.ModuleToFind) then
    begin
      Result := False;
      FindWindowRec.FoundHWnd := Handle;
    end;
  end;
end;
procedure TLiveMirrorManager.AppletModuleActivate(Sender: TObject;
  Data: Integer);
var
  FindWindowRec: TFindWindowRec;
  LiveMirrorMgrPath: String;
begin
  LiveMirrorMgrPath := GetLiveMirrorRoot + 'Manager\LiveMirrorMgr.exe';
  FindWindowRec.ModuleToFind := LiveMirrorMgrPath;
  FindWindowRec.FoundHWnd := 0;
  EnumWindows(@EnumWindowsCallback, integer(@FindWindowRec));
  if FindWindowRec.FoundHWnd = 0 then
    ShellExecute(Application.ControlPanelHandle, 'open', PWideChar(LiveMirrorMgrPath), '', '', SW_NORMAL);
end;

end.
