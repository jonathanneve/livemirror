unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  CcReplicator, CcConf, CcProviders, DB, dconfig, Vcl.SvcMgr,
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

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}
    function CheckLiveMirrorLicence: Boolean;
{$ENDIF}
{$ENDIF}
  public
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

procedure TLiveMirror.ServiceCreate(Sender: TObject);
var
  iniConfigs: TIniFile;
  I: Integer;
  dm: TdmLiveMirrorNode;
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

  //ServiceExecute(Self);
end;

procedure TLiveMirror.ServiceDestroy(Sender: TObject);
begin
  CS.Free;
  CSTerminating.Free;
  slConfigs.Free;
  FRunningThreads.Free;
end;

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}

function TLiveMirror.CheckLiveMirrorLicence: Boolean;
begin
  Result := False;
  if (FDMConfig.Licence <> '') then
  begin
    LogMessage(_('{now} Checking licence information...'));
    try
      if not CheckLicenceActivation(FDMConfig.ConfigName, FDMConfig.Licence) then
      begin
        LogMessage(_('Error checking licence, please check your Internet connection'));
        Exit;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        LogMessage(_('Licencing error : ') + E.Message);
      end;
    end;
  end
  else
    LogMessage(_('No licence set for this database configuration. Synchronization aborting.'));
end;
{$ENDIF}
{$ENDIF}

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

        cConfigName := slConfigs[I];
        if slConfigs.Objects[i] = nil then begin
          node := TdmLiveMirrorNode.Create(Self);
          node.LiveMirrorService := Self;
          node.Initialize(cConfigName);
          slConfigs.Objects[I] := node;
        end else
          node := slConfigs.Objects[i] as TdmLiveMirrorNode;

        if not IsThreadRunning(cConfigName)
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
  except
    on E: Exception do
    begin
      LogMessage(E.Message, EVENTLOG_ERROR_TYPE);
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

// Also implement pausing and stopping the service using a flag in the main and having the threads check it in the onProgress event

end.
