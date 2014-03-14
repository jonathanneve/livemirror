unit LMUtils;

interface

function GetLiveMirrorRoot: String;

const
  LiveMirrorVersion = '1.00.0';

implementation

uses
  Registry, Winapi.Windows, System.Sysutils, gnugettext;

function GetLiveMirrorRoot: String;
var
  reg: TRegistry;
const
  registryPath = 'Software\Microtec\LiveMirror';
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if not reg.KeyExists(registryPath) then
      raise Exception.Create(_('LiveMirror path not configured'));
    reg.OpenKey(registryPath, false);
    Result := reg.ReadString('InstallPath') + '\';
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;

end.
