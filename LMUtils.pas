unit LMUtils;

interface

uses Windows;

function GetLiveMirrorRoot: String;
function RegisteredVersion: Boolean;
function CheckLicence(cConfigName, cLicence: String): Boolean;
function ActivateLicence(cConfigName, cLicence: String): Boolean;
function DeactivateLicence(cConfigName, cLicence: String): Boolean;
function CheckLicenceActivation(cConfigName, cLicence: String): Boolean;
procedure UnInstallService(cConfigName: String; Handle: HWND);
procedure InstallService(cConfigName: String; Handle: HWND);
procedure RunServiceOnce(cConfigName: String; Handle: HWND);


const
  LiveMirrorVersion = '1.2.0 p1';

implementation

uses
  Classes, Registry, System.Sysutils, gnugettext, uLkJSON,
  NB30, httpsend, Dialogs, ShellAPI;

const COPYCAT_URL='http://copycat.fr/amember/softsale/api/';
const OK = 'ok';
const CONNECTION_ERROR = 'connection_error';
// license error codes
const LICENSE_EMPTY = 'license_empty';
const LICENSE_NOT_FOUND = 'license_not_found';
const LICENSE_DISABLED = 'license_disabled';
const LICENSE_EXPIRED = 'license_expired';
const LICENSE_SERVER_ERROR = 'license_server_error';
// activation/deactivation problem codes
const ACTIVATION_SERVER_ERROR = 'activation_server_error';
const ERROR_INVALID_INPUT = 'invalid_input';
const ERROR_NO_SPARE_ACTIVATIONS = 'no_spare_activations';
const ERROR_NO_ACTIVATION_FOUND = 'no_activation_found';
const ERROR_NO_REACTIVATION_ALLOWED = 'no_reactivation_allowed';
const ERROR_NO_RESPONSE = 'no_response';
const ERROR_OTHER = 'other_error';

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
      raise Exception.Create(dgettext('common', 'LiveMirror path not configured'));
    reg.OpenKey(registryPath, false);
    Result := reg.ReadString('InstallPath') + '\';
    reg.CloseKey;
  finally
    reg.Free;
  end;
end;

function RegisteredVersion: Boolean;
begin
  Result := FileExists(GetLiveMirrorRoot + 'licence.dat');
end;


function GetMACAdress: string;
var
  NCB: PNCB;
  Adapter: PAdapterStatus;

  RetCode: Ansichar;
  I: integer;
  Lenum: PlanaEnum;
  _SystemID: string;
begin
  Result    := '';
  _SystemID := '';
  Getmem(NCB, SizeOf(TNCB));
  Fillchar(NCB^, SizeOf(TNCB), 0);

  Getmem(Lenum, SizeOf(TLanaEnum));
  Fillchar(Lenum^, SizeOf(TLanaEnum), 0);

  Getmem(Adapter, SizeOf(TAdapterStatus));
  Fillchar(Adapter^, SizeOf(TAdapterStatus), 0);

  Lenum.Length    := chr(0);
  NCB.ncb_command := chr(NCBENUM);
  NCB.ncb_buffer  := Pointer(Lenum);
  NCB.ncb_length  := SizeOf(Lenum);
  RetCode         := Netbios(NCB);

  i := 0;
  repeat
    Fillchar(NCB^, SizeOf(TNCB), 0);
    Ncb.ncb_command  := chr(NCBRESET);
    Ncb.ncb_lana_num := lenum.lana[I];
    RetCode          := Netbios(Ncb);

    Fillchar(NCB^, SizeOf(TNCB), 0);
    Ncb.ncb_command  := chr(NCBASTAT);
    Ncb.ncb_lana_num := lenum.lana[I];
    // Must be 16
    Ncb.ncb_callname := '*               ';

    Ncb.ncb_buffer := Pointer(Adapter);

    Ncb.ncb_length := SizeOf(TAdapterStatus);
    RetCode        := Netbios(Ncb);
    //---- calc _systemId from mac-address[2-5] XOR mac-address[1]...
    if (RetCode = chr(0)) or (RetCode = chr(6)) then
    begin
      _SystemId := IntToHex(Ord(Adapter.adapter_address[0]), 2) +
        IntToHex(Ord(Adapter.adapter_address[1]), 2) +
        IntToHex(Ord(Adapter.adapter_address[2]), 2) +
        IntToHex(Ord(Adapter.adapter_address[3]), 2) +
        IntToHex(Ord(Adapter.adapter_address[4]), 2) +
        IntToHex(Ord(Adapter.adapter_address[5]), 2);
    end;
    Inc(i);
  until (I >= Ord(Lenum.Length)) or (_SystemID <> '000000000000');
  FreeMem(NCB);
  FreeMem(Adapter);
  FreeMem(Lenum);
  GetMacAdress := _SystemID;
end;

function LicenceRequest(cConfigName, cLicence: String; action: String; var code: String; var cMessage: String): Boolean;
var
  cParams: String;
  slResult: TStringList;
  jsonObj: TlkJSONbase;
  HTTP: THTTPSend;
begin
  Result := False;
  cParams := '?key=' + cLicence + '&request[hardware-id]=' + GetMACAdress + cConfigName;
  slResult := TStringList.Create;
  HTTP := THTTPSend.Create;
  try
    if HTTP.HTTPMethod('GET', COPYCAT_URL + action + cParams) then begin
      if HTTP.ResultCode = 200 then begin
        slResult.LoadFromStream(HTTP.Document);
        jsonObj := TlkJSON.ParseText(slResult.Text);
        code := jsonObj.Field['code'].Value;
        cMessage := jsonObj.Field['message'].Value;
        if code = OK then
          Result := True
        else if code = CONNECTION_ERROR then
          raise Exception.Create(dgettext('common', 'Error connecting to licence server!'#13#10'Please make sure your Internet connection is available.') + #13#10 + cMessage)
        else if code = LICENSE_EMPTY then
          raise Exception.Create(dgettext('common', 'Empty or invalid licence key submitted'))
        else if code = LICENSE_NOT_FOUND then
          raise Exception.Create(dgettext('common', 'Licence key invalid'))
        else if code = LICENSE_DISABLED then
          raise Exception.Create(dgettext('common', 'Licence key has been disabled'))
        else if code = LICENSE_EXPIRED then
          raise Exception.Create(dgettext('common', 'License key expired'))
        else if code = LICENSE_SERVER_ERROR then
          raise Exception.Create(dgettext('common', 'Licence server is not available - please try again later'))
        else if code = ACTIVATION_SERVER_ERROR then
          raise Exception.Create(dgettext('common', 'Activation server error'))
        else if code = ERROR_INVALID_INPUT then
          raise Exception.Create(dgettext('common', 'Activation failed: invalid input' + #13#10 + cMessage))
        else if code = ERROR_NO_SPARE_ACTIVATIONS then
          raise Exception.Create(dgettext('common', 'Sorry, this licence key has already been activated for a different database or on a different machine. You need to purchase one licence of LiveMirror per master database that you want to mirror.'))
        else if code = ERROR_NO_ACTIVATION_FOUND then
          raise Exception.Create(dgettext('common', 'Sorry, we have not found an activation record to deactivate'))
        else if code = ERROR_NO_RESPONSE then
          raise Exception.Create(dgettext('common', 'Internal problem on activation server'))
        else if code = ERROR_NO_REACTIVATION_ALLOWED then
          raise Exception.Create(dgettext('common', 'Sorry, license re-activation limit reached'))
        else if code = ERROR_OTHER then
          raise Exception.Create(dgettext('common', 'Error returned from activation server'));
      end;
    end;
  finally
    slResult.Free;
    HTTP.Free;
  end;
end;

function CheckLicence(cConfigName, cLicence: String): Boolean;
var
  cCode, cMessage: String;
begin
  Result := LicenceRequest(cConfigName, cLicence, 'check-license', cCode, cMessage); 
end;

function ActivateLicence(cConfigName, cLicence: String): Boolean;
var
  cCode, cMessage: String;
begin
  Result := LicenceRequest(cConfigName, cLicence, 'activate', cCode, cMessage);
end;

function DeactivateLicence(cConfigName, cLicence: String): Boolean;
var
  cCode, cMessage: String;
begin
  if cLicence <> '' then
    Result := LicenceRequest(cConfigName, cLicence, 'deactivate', cCode, cMessage)
  else
    Result := True;
end;

function CheckLicenceActivation(cConfigName, cLicence: String): Boolean;
var
  cCode, cMessage: String;
begin
  Result := LicenceRequest(cConfigName, cLicence, 'check-activation', cCode, cMessage);
end;

function CheckLicences: Boolean;
{var
  cLicenceFile: String;
  slLicences: TStringList;
  I:Integer;}
begin
{  Result := False;
  cLicenceFile := GetLiveMirrorRoot + 'licence.dat';
  if FileExists(cLicenceFile) then begin
    slLicences := TStringList.Create;
    try
      slLicences.LoadFromFile(cLicenceFile);
      for I:=0 to slLicences.Count - 1 do begin
        Result := CheckLicence(slLicences[I]);
      end;
    finally
      slLicences.Free;
    end;
  end;}
end;

procedure UnInstallService(cConfigName: String; Handle: HWND);
begin
  if ShellExecute(Handle,'open',PChar(GetLiveMirrorRoot + '\Service\LiveMirrorSrv.exe'), PChar(cConfigName + ' /uninstall /silent'),'',SW_HIDE) < 32 then
    raise Exception.Create(dgettext('common', 'Can''t uninstall service!'));
end;

procedure InstallService(cConfigName: String; Handle: HWND);
begin
  if ShellExecute(Handle,'open',PChar(GetLiveMirrorRoot + '\Service\LiveMirrorSrv.exe'), PChar(cConfigName + ' /install /silent'),'',SW_HIDE) <= 32 then
    raise Exception.Create(dgettext('common', 'Can''t install service!' + #13#10 + 'Please make sure you have are running with administrator rights.'));
end;

procedure RunServiceOnce(cConfigName: String; Handle: HWND);
begin
  if ShellExecute(Handle,'open',PChar(GetLiveMirrorRoot + '\Service\LiveMirrorSrv.exe'), PChar(cConfigName + ' /runonce'),'',SW_HIDE) <= 32 then
    raise Exception.Create(dgettext('common', 'Can''t run synchronization!' + #13#10 + 'Please make sure you have are running with administrator rights.'));
end;

end.
