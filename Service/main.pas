unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  CcReplicator, CcConf, CcProviders, DB, dconfig, Vcl.SvcMgr, dLiveMirrorNode,
  EExceptionManager, CcDB, SyncObjs, System.Generics.Collections;

type
  TLiveMirror = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceShutdown(Sender: TService);
  private
    CS: TCriticalSection;
    slConfigs: TStringList;
    FRunningThreads: TDictionary<String, TThread>;
    FMaxSimultaneousReplications: Integer;
    FLiveMirrorTerminating: Boolean;
    CSTerminating: TCriticalSection;
    function GetTotalThreadsRunning: Integer;
    procedure SetLiveMirrorTerminating(const Value: Boolean);
    function GetLiveMirrorTerminating: Boolean;
    function IsThreadRunning(configName: String): Boolean;
    function GetNode(cConfigName: String): TdmLiveMirrorNode;
    function RunningThreadCount: Integer;

  public
    lRunOnce: Boolean;
    property LiveMirrorTerminating : Boolean read FLiveMirrorTerminating;
    procedure AddRunningThread(configName: String; th: TThread);
    procedure RemoveRunningThread(configName: String);
    property TotalThreadsRunning: Integer read GetTotalThreadsRunning;
    function GetServiceController: TServiceController; override;
    { Déclarations publiques }
  end;

var
  LiveMirror: TLiveMirror;

implementation

{$R *.DFM}

uses LMUtils, IniFiles, dInterbase, Registry, gnugettext,
  LiveMirrorRunnerThread;

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
    Result := FRunningThreads.Count;
  finally
    CS.Leave;
  end;
end;

procedure TLiveMirror.AddRunningThread(configName: String; th: TThread);
begin
  CS.Enter;
  try
    FRunningThreads.Add(configName, th);
    LogMessage('LiveMirror replication running for configuration "' + configName + '" - ' + IntToStr(FRunningThreads.Count) + ' threads currenting running in total', EVENTLOG_INFORMATION_TYPE);
  finally
    CS.Leave;
  end;
end;

procedure TLiveMirror.RemoveRunningThread(configName: String);
begin
  CS.Enter;
  try
    FRunningThreads.Remove(configName);
    LogMessage('LiveMirror replication finished for configuration "' + configName + '" - ' + IntToStr(FRunningThreads.Count) + ' threads still running', EVENTLOG_INFORMATION_TYPE);
  finally
    CS.Leave;
  end;
end;

function TLiveMirror.IsThreadRunning(configName: String): Boolean;
begin
  CS.Enter;
  try
    Result := FRunningThreads.ContainsKey(configName);
  finally
    CS.Leave;
  end;
end;

function TLiveMirror.RunningThreadCount: Integer;
begin
  CS.Enter;
  try
    Result := FRunningThreads.Count;
  finally
    CS.Leave;
  end;
end;

procedure TLiveMirror.ServiceCreate(Sender: TObject);
var
  iniConfigs: TIniFile;
  I: Integer;
  dm: TdmLiveMirrorNode;
  node: TdmLiveMirrorNode;
begin
  LogMessage('LiveMirror service starting', EVENTLOG_INFORMATION_TYPE);

  FRunningThreads := TDictionary<String, TThread>.Create;
  FMaxSimultaneousReplications := 10;
  CS := TCriticalSection.Create;
  CSTerminating := TCriticalSection.Create;
  slConfigs := TStringList.Create;
  iniConfigs := TIniFile.Create(GetLiveMirrorRoot + '\configs.ini');
  try
    iniConfigs.ReadSections(slConfigs);
  finally
    iniConfigs.Free;
  end;
  LogMessage('LiveMirror service started', EVENTLOG_INFORMATION_TYPE);

 //  GetNode('UCAR').Run;
  if ParamStr(2) = '/runonce' then begin
    lRunOnce := True;
    node := GetNode(ParamStr(1));
    if Assigned(node) then
      node.Run;
  end else
    lRunOnce := False;
end;

procedure TLiveMirror.ServiceDestroy(Sender: TObject);
begin
  CS.Free;
  CSTerminating.Free;
  slConfigs.Free;
  FRunningThreads.Free;
end;

procedure TLiveMirror.ServiceExecute(Sender: TService);
var
  I: Integer;
  dm: TdmLiveMirrorNode;
  node: TdmLiveMirrorNode;
  th: TLiveMirrorRunnerThread;
  cConfigName: String;
begin
  try
    while not Terminated do
    begin
      ServiceThread.ProcessRequests(False);
      for I := 0 to slConfigs.Count-1 do begin
        while GetTotalThreadsRunning >= FMaxSimultaneousReplications do begin
          LogMessage('LiveMirror thread limit reached, waiting...', EVENTLOG_INFORMATION_TYPE);
          Sleep(500);
        end;

        if LiveMirrorTerminating then
          Break;

        cConfigName := slConfigs[i];
        node := GetNode(cConfigName);

        if (node <> nil) and not IsThreadRunning(cConfigName)
           and (GetTickCount > (node.LastReplicationTickCount + (node.DMConfig.SyncFrequency * 1000))) then
        begin
          LogMessage('LiveMirror thread starting...', EVENTLOG_INFORMATION_TYPE);
          th := TLiveMirrorRunnerThread.Create(True);
          th.Node := node;
          AddRunningThread(cConfigName, th);
          th.Start;
        end;

        if Terminated then
          Break;
        ServiceThread.ProcessRequests(False);
      end;
      if Terminated then
        Break;
      Sleep(500);
    end;

    while RunningThreadCount > 0 do
      Sleep(500);
  except
    on E: Exception do
    begin
      LogMessage(E.Message, EVENTLOG_ERROR_TYPE);
    end;
  end;
end;

function TLiveMirror.GetNode(cConfigName: String): TdmLiveMirrorNode;
var
  I: Integer;
begin
  I := slConfigs.IndexOf(cConfigName);
  if slConfigs.Objects[i] = nil then begin
    Result := TdmLiveMirrorNode.Create(Self);
    Result.LiveMirrorService := Self;
    slConfigs.Objects[I] := Result;
  end else
    Result := slConfigs.Objects[i] as TdmLiveMirrorNode;

  if not Result.Initialized then
  begin
    if Result.Initialize(cConfigName) then
      Result.Initialized := True
    else begin
      Result := nil;
      Exit;
    end;
  end;
end;

procedure TLiveMirror.ServiceShutdown(Sender: TService);
begin
  LogMessage('LiveMirror service shutting down, waiting for threads to finish...', EVENTLOG_INFORMATION_TYPE);
  SetLiveMirrorTerminating(True);
  while GetTotalThreadsRunning > 0 do
    Sleep(100);
  LogMessage('LiveMirror service shut down', EVENTLOG_INFORMATION_TYPE);
end;

procedure TLiveMirror.SetLiveMirrorTerminating(const Value: Boolean);
begin
  CSTerminating.Enter;
  try
    FLiveMirrorTerminating := Value;
  finally
    CSTerminating.Leave;
  end;
end;

function TLiveMirror.GetLiveMirrorTerminating: Boolean;
begin
  CSTerminating.Enter;
  try
    Result := FLiveMirrorTerminating;
  finally
    CSTerminating.Leave;
  end;
end;

end.
