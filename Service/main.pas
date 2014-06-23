unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  CcReplicator, CcConf, CcProviders, DB, dconfig, CcConfStorage, Vcl.SvcMgr;

type
  TLiveMirror = class(TService)
    Replicator: TCcReplicator;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ReplicatorLogLoaded(Sender: TObject);
    procedure ReplicatorRowReplicated(Sender: TObject; TableName: string;
      Fields: TFields);
    procedure ReplicatorReplicationError(Sender: TObject; e: Exception;
      var CanContinue: Boolean);
    procedure ReplicatorException(Sender: TObject; e: Exception);
    procedure ReplicatorFinished(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ReplicatorEmptyLog(Sender: TObject);
  private
    FDMConfig: TdmConfig;
    FRunOnce: Boolean;
    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    function CheckLiveMirrorLicence : Boolean;
    {$ENDIF}
    {$ENDIF}

    function ConfigDatabases: Boolean;
  public
    procedure Initialize;
    function GetServiceController: TServiceController; override;
    { Déclarations publiques }
  end;

var
  LiveMirror: TLiveMirror;

implementation

{$R *.DFM}

uses LMUtils, IniFiles, dInterbase, Registry, HotLog, gnugettext;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  LiveMirror.Controller(CtrlCode);
end;

function TLiveMirror.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TLiveMirror.ReplicatorEmptyLog(Sender: TObject);
begin
  if FRunOnce then
    hLog.Add(_('{now} Nothing to replicate'));
end;

procedure TLiveMirror.ReplicatorException(Sender: TObject; e: Exception);
begin
  LogMessage(_('Replication failed with error : ') + #13#10 + e.Message, EVENTLOG_ERROR_TYPE);
	hLog.Add('{now} ' + _('Replication failed with error : '));
	hLog.AddException(e);
end;

procedure TLiveMirror.ReplicatorFinished(Sender: TObject);
begin
//  LogMessage('Replication finished : ' + #13#10 + 'Rows replicated : ' + IntToStr(Replicator.LastResult.RowsReplicated)
//  + #13#10 + 'Rows with errors : ' + IntToStr(Replicator.LastResult.RowsErrors)
//   , EVENTLOG_INFORMATION_TYPE);
  hLog.Add(_('Replication finished : ') + #13#10 + _('Rows replicated : ') + IntToStr(Replicator.LastResult.RowsReplicated)
  + #13#10 + _('Rows with errors : ') + IntToStr(Replicator.LastResult.RowsErrors));
end;

procedure TLiveMirror.ReplicatorLogLoaded(Sender: TObject);
begin
//  LogMessage('Starting replication : ' + IntToStr(Replicator.Log.LineCount) + ' rows to replicate...', EVENTLOG_INFORMATION_TYPE);
	hLog.Add('{now} ' + _('Starting replication : ') + IntToStr(Replicator.Log.LineCount) + _(' rows to replicate...'));
end;

procedure TLiveMirror.ReplicatorReplicationError(Sender: TObject; e: Exception;
  var CanContinue: Boolean);
begin
  LogMessage(_('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.PrimaryKeys + ']' + #13#10 + e.Message, EVENTLOG_WARNING_TYPE);
	hLog.Add('{now} ' + _('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');
	hLog.AddException(e);
end;

procedure TLiveMirror.ReplicatorRowReplicated(Sender: TObject;
  TableName: string; Fields: TFields);
begin
//  LogMessage('Row replicated : Table ' + TableName + ' [' +  Replicator.Log.PrimaryKeys + ']', EVENTLOG_INFORMATION_TYPE);
  hLog.Add('{now} ' + _('Row replicated : Table : ') + TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');
	Replicator.LocalDB.CommitRetaining;
	Replicator.RemoteDB.CommitRetaining;
end;

function TLiveMirror.ConfigDatabases: Boolean;
var
  slTables: TStringList;
  I: Integer;
  slExcludedTables: TStringList;
begin
  Result := False;
 	hLog.Add(_('{now} Checking database configuration...'));
  LogMessage('Configuring databases for replication...', EVENTLOG_INFORMATION_TYPE);
  try
    FDMConfig.ConfigureNodes;
    FDMConfig.SaveConfig; //We save the config file so that the MetaDataCreated field gets set
    hLog.Add(_('{now} Databases configuration configured successfully!'));
    Result := True;
  except on E:Exception do
    begin
      hLog.Add(_('{now} Error setting up databases for replication!'));
      hLog.AddException(E);
    end;
  end;
end;

procedure TLiveMirror.ServiceAfterInstall(Sender: TService);
begin
  with TRegistry.Create(KEY_READ or KEY_WRITE) do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey('SYSTEM\CurrentControlSet\Services\' + Name, True) then
    begin
      WriteString('ImagePath', ReadString('ImagePath')+' ' + FDMConfig.ConfigName);
      WriteString('Description', 'Microtec LiveMirror replication service'{$IFDEF LM_EVALUATION} + ' EVALUATION VERSION' {$ENDIF} );
    end
  finally
    Free;
  end;
end;

procedure TLiveMirror.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  Replicator.AutoReplicate.Start;
end;

procedure TLiveMirror.ServiceCreate(Sender: TObject);
begin
  FDMConfig := TdmConfig.Create(Self);
  FDMConfig.ConfigName := ParamStr(1);
  Name := 'LiveMirror' + FDMConfig.ConfigName;
  DisplayName := DisplayName + ' (' + FDMConfig.ConfigName + ')';

  FRunOnce := False;
  if ParamStr(2) = '/runonce' then begin
    FRunOnce := True;
    Initialize;
  end;
end;

procedure TLiveMirror.ServiceDestroy(Sender: TObject);
begin
  FDMConfig.Free;
end;

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}
function TLiveMirror.CheckLiveMirrorLicence : Boolean;
begin
  Result := False;
  if (FDMConfig.Licence <> '') then begin
     hLog.Add(_('{now} Checking licence information...'));
     try
       if not CheckLicenceActivation(FDMConfig.ConfigName, FDMConfig.Licence) then begin
         hLog.Add(_('Error checking licence, please check your Internet connection'));
         Exit;
       end;
       Result := True;
     except
       on E: Exception do begin
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

procedure TLiveMirror.Initialize;
var
  iniConfigs: TIniFile;
  cPath: String;
  nReplFrequency: Integer;
  cErrorMessage: String;
begin
  try
    FDMConfig.LoadConfig(FDMConfig.ConfigName);

    with hLog.hlWriter.hlFileDef do begin
      path := GetLiveMirrorRoot + '\Configs\' + FDMConfig.ConfigName + '\log\';
      SafegdgMax := 100;
      UseSafeFilenames := true;
      UseFileSizeLimit := true;
      BuildSafeFileName;
      LogFileMaxSize := OneMegabyte;
    end;
    hlog.SetLogFileTimerInterval(OneMinute);
    hLog.StartLogging;
    hLog.Add('{/}{LNumOff}{*80*}');
    hLog.Add(_('>>>> Start {App_name}') + ' v ' + LiveMirrorVersion + '{80@}{&}{dte} {hms}{&}');
    hLog.Add(_('{@12}Path : {App_path}'));
    hLog.Add(_('{@12}Config. name : {App_prm-}{/}'));

    {$IFDEF LM_EVALUATION}
    hLog.Add(_('!!! EVALUATION VERSION !!!'));
    {$ENDIF}

    hLog.Add(_('MASTER database :') + #9 + FDMConfig.MasterNode.Description);
    hLog.Add(_('MIRROR database :') + #9 + FDMConfig.MirrorNode.Description);
    hLog.Add(_('Replication frequency :') + #9 + IntToStr(FDMConfig.SyncFrequency) + _(' seconds'));
    hLog.Add('{/}{LNumOff}{*80*}');

    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    //Check licence and die if it's incorrect
    if not CheckLiveMirrorLicence then begin
      //Clear licence if it was incorrect
      LogMessage(Format(_('LiveMirror licence invalid for configuration %s.'#13#10'Clearing licence information from setup.'#13#10'Database will not be synchronized till licence is corrected.'), [FDMConfig.ConfigName]), EVENTLOG_ERROR_TYPE);
      FDMConfig.Licence := '';
      FDMConfig.SaveConfig;
      Abort;
    end;
    {$ENDIF}
    {$ENDIF}

    //Create replication meta-data and triggers if they aren't there
    //Any new tables are automatically detected and triggers added
    if ConfigDatabases then begin
      Replicator.AutoReplicate.Frequency := FDMConfig.SyncFrequency;
      Replicator.AutoReplicate.Enabled := True;
      Replicator.LocalNode.Connection := FDMConfig.MasterNode.Connection;
      Replicator.LocalNode.Name := 'MASTER';
      Replicator.RemoteNode.Connection := FDMConfig.MirrorNode.Connection;
      Replicator.RemoteNode.Name := 'MIRROR';

      hLog.Add(_('{now} Service ready!'));

      if FRunOnce then
        Replicator.Replicate
      else
        Replicator.AutoReplicate.Start;
    end else begin
      cErrorMessage := _('{now} DATABASE CONFIGURATION FAILED - CONTACT COPYCAT TEAM FOR SUPPORT!');
      hLog.Add(cErrorMessage);
      LogMessage(cErrorMessage, EVENTLOG_ERROR_TYPE);
    end;
  except on E: Exception do begin
      LogMessage(E.Message, EVENTLOG_ERROR_TYPE);
      iniConfigs.Free;
    end;
  end;
end;

procedure TLiveMirror.ServiceExecute(Sender: TService);
begin
  Initialize;
  while not Terminated do begin
    ServiceThread.ProcessRequests(true);
    Sleep(500);
  end;
end;

procedure TLiveMirror.ServicePause(Sender: TService; var Paused: Boolean);
begin
  Replicator.AutoReplicate.Stop;
  Replicator.AbortReplication;
end;

procedure TLiveMirror.ServiceShutdown(Sender: TService);
begin
  Replicator.AutoReplicate.Stop;
  Replicator.AbortReplication;
end;

procedure TLiveMirror.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Replicator.AutoReplicate.Start;
end;

procedure TLiveMirror.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Replicator.AutoReplicate.Stop;
  Replicator.AbortReplication;
end;

end.
