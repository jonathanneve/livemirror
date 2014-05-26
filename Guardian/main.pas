unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.SvcMgr, Vcl.Dialogs, ServiceManager, IniFiles, Vcl.StdCtrls;

type
  TLiveMirror = class(TService)
    procedure ServiceExecute(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
  private
    serviceMgr: TServiceManager;
    slConfigs: TStringList;
    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    function CheckServiceLicence(cConfigName: String): Boolean;
    {$ENDIF}
    {$ENDIF}
    procedure StopServices;
  public
    function GetServiceController: TServiceController; override;
    { Déclarations publiques }
  end;

var
  LiveMirror: TLiveMirror;

implementation

{$R *.DFM}

uses LMUtils, ShellAPI, Registry;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  LiveMirror.Controller(CtrlCode);
end;

function TLiveMirror.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TLiveMirror.ServiceAfterInstall(Sender: TService);
begin
  with TRegistry.Create(KEY_READ or KEY_WRITE) do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey('SYSTEM\CurrentControlSet\Services\' + Name, True) then
    begin
      WriteString('Description', 'Microtec LiveMirror guardian service' {$IFDEF LM_EVALUATION} + ' EVALUATION VERSION' {$ENDIF});
    end
  finally
    Free;
  end;
end;

procedure TLiveMirror.ServiceCreate(Sender: TObject);
var
  iniConfigs : TIniFile;
begin
  serviceMgr := TServiceManager.Create;
  slConfigs := TStringList.Create;
  iniConfigs := TIniFile.Create(GetLiveMirrorRoot + '\configs.ini');
  try
    iniConfigs.ReadSections(slConfigs);
  finally
    iniConfigs.Free;
  end;
end;

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}
function TLiveMirror.CheckServiceLicence(cConfigName: String): Boolean;
var
  iniConfigs : TIniFile;
  cLicence: String;
begin
  iniConfigs := TIniFile.Create(GetLiveMirrorRoot + '\configs.ini');
  try
    cLicence := iniConfigs.ReadString(cConfigName, 'Licence', '');
    Result := (cLicence <> '');
  finally
    iniConfigs.Free;
  end;
end;
{$ENDIF}
{$ENDIF}

procedure TLiveMirror.ServiceDestroy(Sender: TObject);
begin
  serviceMgr.Free;
  slConfigs.Free;
end;

procedure TLiveMirror.ServiceExecute(Sender: TService);
var
  I: Integer;
  srv: TServiceInfo;

  {$IFDEF LM_EVALUATION}
  timeStarted: TDateTime;
  {$ENDIF}

function EvalTimeExpired: Boolean;
begin
  {$IFDEF LM_EVALUATION}
  Result := (Now - timeStarted > 1 / 24); //Close Guardian after 1 hour
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

begin
  {$IFDEF LM_EVALUATION}
  timeStarted := Now;
  {$ENDIF}

  while not Terminated do
  begin
    if EvalTimeExpired then begin
      LogMessage('LiveMirror evaluation version, shutting down service...');
      StopServices;
      break;
    end;

    ServiceThread.ProcessRequests(False);
    try
      for I := 0 to slConfigs.Count-1 do begin
        serviceMgr.Active := False;
        serviceMgr.Active := True;

        if Status <> csRunning then
          Break;

        srv := serviceMgr.ServiceByName['LiveMirror' + slConfigs[I]];
        if srv.State <> ssRunning then begin
          {$IFNDEF LM_EVALUATION}
          {$IFNDEF DEBUG}
          if CheckServiceLicence(slConfigs[I]) then
          {$ENDIF}
          {$ENDIF}
          srv.ServiceStart(false);
        end;
        ServiceThread.ProcessRequests(False);
      end;
    except on E:Exception do begin
        LogMessage(E.Message, EVENTLOG_ERROR_TYPE);
      end;
    end;
    Sleep(500);
  end;
end;

procedure TLiveMirror.ServiceShutdown(Sender: TService);
var
  I: Integer;
  srv: TServiceInfo;
begin
{  for I := 0 to slConfigs.Count-1 do begin
    serviceMgr.Active := False;
    serviceMgr.Active := True;
    srv := serviceMgr.ServiceByName['LiveMirror' + slConfigs[I]];
    if srv.State = ssRunning then
      srv.ServiceStop(false);
  end;                          }
end;

procedure TLiveMirror.StopServices;
var
  I: Integer;
  srv: TServiceInfo;
begin
  try
    for I := 0 to slConfigs.Count-1 do begin
      serviceMgr.Active := False;
      serviceMgr.Active := True;
      srv := serviceMgr.ServiceByName['LiveMirror' + slConfigs[I]];
      if srv.State = ssRunning then
        srv.ServiceStop(false);
    end;
  except on E:Exception do begin
      LogMessage(E.Message, EVENTLOG_ERROR_TYPE);
    end;
  end;
end;

procedure TLiveMirror.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  StopServices;
end;

end.
