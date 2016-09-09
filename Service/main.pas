unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  CcReplicator, CcConf, CcProviders, DB, dconfig, Vcl.SvcMgr,
  EExceptionManager, CcDB, SyncObjs;

type
  TLiveMirror = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceDestroy(Sender: TObject);
  private
    CS: TCriticalSection;
    slConfigs: TStringList;
    FTotalThreadsRunning: Integer;
    FMaxSimultaneousReplications: Integer;
    function GetTotalThreadsRunning: Integer;
    procedure SetTotalThreadsRunning(const Value: Integer);

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}
    function CheckLiveMirrorLicence: Boolean;
{$ENDIF}
{$ENDIF}
  public
    procedure IncTotalThreadsRunning;
    procedure DecTotalThreadsRunning;
    property TotalThreadsRunning: Integer read GetTotalThreadsRunning write SetTotalThreadsRunning;
    function GetServiceController: TServiceController; override;
    { Déclarations publiques }
  end;

var
  LiveMirror: TLiveMirror;

implementation

{$R *.DFM}

uses LMUtils, IniFiles, dInterbase, Registry, HotLog, gnugettext,
  dLiveMirrorNode, LiveMirrorRunnerThread;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  LiveMirror.Controller(CtrlCode);
end;

function TLiveMirror.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

function TLiveMirror.GetTotalThreadsRunning: Integer;
begin
  CS.Enter;
  try
    Result := FTotalThreadsRunning;
  finally
    CS.Leave;
  end;
end;

procedure TLiveMirror.IncTotalThreadsRunning;
begin
  CS.Enter;
  try
    LogMessage('LiveMirror new thread: ' + IntToStr(FTotalThreadsRunning) + ' total', EVENTLOG_INFORMATION_TYPE);
    Inc(FTotalThreadsRunning);
  finally
    CS.Leave;
  end;
end;

procedure TLiveMirror.DecTotalThreadsRunning;
begin
  CS.Enter;
  try
    LogMessage('LiveMirror thread stopped: ' + IntToStr(FTotalThreadsRunning) + ' left', EVENTLOG_INFORMATION_TYPE);
    Dec(FTotalThreadsRunning);
  finally
    CS.Leave;
  end;
end;

procedure TLiveMirror.ServiceCreate(Sender: TObject);
var
  iniConfigs: TIniFile;
  I: Integer;
  dm: TdmLiveMirrorNode;
begin
  LogMessage('LiveMirror service starting', EVENTLOG_INFORMATION_TYPE);

  FTotalThreadsRunning := 0;
  FMaxSimultaneousReplications := 10;
  CS := TCriticalSection.Create;
  slConfigs := TStringList.Create;
  iniConfigs := TIniFile.Create(GetLiveMirrorRoot + '\configs.ini');
  try
    iniConfigs.ReadSections(slConfigs);
  finally
    iniConfigs.Free;
  end;
  LogMessage('LiveMirror service started', EVENTLOG_INFORMATION_TYPE);
end;

procedure TLiveMirror.ServiceDestroy(Sender: TObject);
begin
  CS.Free;
  slConfigs.Free;
end;

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}

function TLiveMirror.CheckLiveMirrorLicence: Boolean;
begin
  Result := False;
  if (FDMConfig.Licence <> '') then
  begin
    hLog.Add(_('{now} Checking licence information...'));
    try
      if not CheckLicenceActivation(FDMConfig.ConfigName, FDMConfig.Licence) then
      begin
        hLog.Add(_('Error checking licence, please check your Internet connection'));
        Exit;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        hLog.Add(_('Licencing error : '));
        hLog.Add(E.Message);
      end;
    end;
  end
  else
    hLog.Add(_('No licence set for this database configuration. Synchronization aborting.'));
end;
{$ENDIF}
{$ENDIF}

procedure TLiveMirror.ServiceExecute(Sender: TService);
var
  I: Integer;
  srv: TServiceInfo;
  dm: TdmLiveMirrorNode;
  node: TdmLiveMirrorNode;
  th: TLiveMirrorRunnerThread;
begin
  try
  {  for I := 0 to slConfigs.Count - 1 do
    begin
      dm := TdmLiveMirrorNode.Create(Self);
      dm.LiveMirrorService := Self;
      dm.Initialize(slConfigs[I]);
      slConfigs.Objects[I] := dm;
    end;}
    with TStringList.Create do begin Text := 'TEST1'; SaveToFile('C:\Temp\progress.txt');Free;end;

    while not Terminated do
    begin
      with TStringList.Create do begin Text := 'TEST2'; SaveToFile('C:\Temp\progress.txt');Free;end;

      ServiceThread.ProcessRequests(False);
    with TStringList.Create do begin Text := 'TEST2-2'; SaveToFile('C:\Temp\progress.txt');Free;end;
      for I := 0 to slConfigs.Count-1 do begin
        LogMessage('LiveMirror looping...', EVENTLOG_INFORMATION_TYPE);
    with TStringList.Create do begin Text := 'TEST3'; SaveToFile('C:\Temp\progress.txt');Free;end;

        while GetTotalThreadsRunning >= FMaxSimultaneousReplications do begin
          LogMessage('LiveMirror thread limit reached, waiting...', EVENTLOG_INFORMATION_TYPE);
          Sleep(500);
        end;
        LogMessage('LiveMirror past while', EVENTLOG_INFORMATION_TYPE);
     with TStringList.Create do begin Text := 'TEST4'; SaveToFile('C:\Temp\progress.txt');Free;end;

        if slConfigs.Objects[i] = nil then begin
  LogMessage('LiveMirror creating datamodule', EVENTLOG_INFORMATION_TYPE);
          node := TdmLiveMirrorNode.Create(Self);
          node.LiveMirrorService := Self;
          node.Initialize(slConfigs[I]);
          slConfigs.Objects[I] := node;
        end else
          node := slConfigs.Objects[i] as TdmLiveMirrorNode;

        if GetTickCount > (node.LastReplicationTickCount + (node.DMConfig.SyncFrequency * 1000)) then begin
          LogMessage('LiveMirror thread starting...', EVENTLOG_INFORMATION_TYPE);
          th := TLiveMirrorRunnerThread.Create(True);
          th.Node := node;
          th.Start;
          IncTotalThreadsRunning;
        end;
      end;
    end;

  except
    on E: Exception do
    begin
      LogMessage(E.Message, EVENTLOG_ERROR_TYPE);
    end;
  end;
  (* Initialize;
    while not Terminated do begin
    ServiceThread.ProcessRequests(true);

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


    FDMConfig := TdmConfig.Create(Self);
    FDMConfig.ConfigName := ParamStr(1);

    Sleep(500);
    end; *)
end;

procedure TLiveMirror.SetTotalThreadsRunning(const Value: Integer);
begin
  CS.Enter;
  try
    FTotalThreadsRunning := Value;
  finally
    CS.Leave;
  end;
end;


// Also implement pausing and stopping the service using a flag in the main and having the threads check it in the onProgress event

end.
