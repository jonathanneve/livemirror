unit dLiveMirrorRunner;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  CcReplicator, CcConf, CcProviders, DB, dconfig, Vcl.SvcMgr,
  EExceptionManager, CcDB;

type
  TdmLiveMirrorRunner = class(TDataModule)
    Replicator: TCcReplicator;
    qGenerators: TCcQuery;
    qSyncGenerator: TCcQuery;
    CcQuery1: TCcQuery;
    qGetGenValue: TCcQuery;
    qMirrorGenerators: TCcQuery;
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ReplicatorLogLoaded(Sender: TObject);
    procedure ReplicatorException(Sender: TObject; e: Exception);
    procedure ReplicatorFinished(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ReplicatorEmptyLog(Sender: TObject);
    procedure ReplicatorConnectionLost(Sender: TObject;
      Database: TCcConnection);
    procedure ReplicatorReplicationAborted(Sender: TObject);
    procedure ReplicatorReplicationResult(Sender: TObject);
    procedure ReplicatorReplicationError(Sender: TObject; e: Exception;
      var CanContinue, SkipToRemote: Boolean);
    procedure ReplicatorRowReplicated(Sender: TObject; TableName: string;
      Fields: TCcMemoryFields; QueryType: TCcQueryType);
  private
    FDMConfig: TdmConfig;
    FRunOnce: Boolean;
    FLiveMirrorService: TService;
    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    function CheckLiveMirrorLicence : Boolean;
    {$ENDIF}
    {$ENDIF}

    function ConfigDatabases: Boolean;
    procedure ReplicateGenerators;
  public
    procedure Initialize;
    function GetServiceController: TServiceController; override;
    { Déclarations publiques }
  end;

var
  dmLiveMirrorRunner: TdmLiveMirrorRunner;

implementation

{$R *.DFM}

uses LMUtils, IniFiles, dInterbase, Registry, HotLog, gnugettext;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
end;

function TdmLiveMirrorRunner.GetServiceController: TServiceController;
begin
end;

procedure TdmLiveMirrorRunner.ReplicatorConnectionLost(Sender: TObject;
  Database: TCcConnection);
var
  dbNode: String;
begin
  if Database = Replicator.LocalDB then
    dbNode := Replicator.LocalNode.Name
  else
    dbNode := Replicator.RemoteNode.Name;

  hLog.Add(Format(_('Connection lost to database : %s'), [dbNode]));
end;

procedure TdmLiveMirrorRunner.ReplicatorEmptyLog(Sender: TObject);
begin
  if FRunOnce then
    hLog.Add(_('{now} Nothing to replicate'));
end;

procedure TdmLiveMirrorRunner.ReplicatorException(Sender: TObject; e: Exception);
begin
  FLiveMirrorService.LogMessage(_('Replication failed with error : ') + #13#10 + e.Message, EVENTLOG_ERROR_TYPE);
	hLog.Add('{now} ' + _('Replication failed with error : '));
	hLog.AddException(e);
  hLog.Add(E.StackTrace);
  ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr)
end;

procedure TdmLiveMirrorRunner.ReplicatorFinished(Sender: TObject);
begin
//  LogMessage('Replication finished : ' + #13#10 + 'Rows replicated : ' + IntToStr(Replicator.LastResult.RowsReplicated)
//  + #13#10 + 'Rows with errors : ' + IntToStr(Replicator.LastResult.RowsErrors)
//   , EVENTLOG_INFORMATION_TYPE);
  hLog.Add(_('Replication finished : ') + #13#10 + _('Rows replicated : ') + IntToStr(Replicator.LastResult.RowsReplicated)
  + #13#10 + _('Rows with errors : ') + IntToStr(Replicator.LastResult.RowsErrors));
end;

procedure TdmLiveMirrorRunner.ReplicatorLogLoaded(Sender: TObject);
begin
//  LogMessage('Starting replication : ' + IntToStr(Replicator.Log.LineCount) + ' rows to replicate...', EVENTLOG_INFORMATION_TYPE);
	hLog.Add('{now} ' + _('Starting replication : '));// + IntToStr(Replicator.Log.LineCount) + _(' rows to replicate...'));
end;

procedure TdmLiveMirrorRunner.ReplicatorReplicationAborted(Sender: TObject);
begin
  hLog.Add('{now} Replication aborted!');
end;

procedure TdmLiveMirrorRunner.ReplicatorReplicationError(Sender: TObject; e: Exception;
  var CanContinue, SkipToRemote: Boolean);
begin
  FLiveMirrorService.LogMessage(_('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.PrimaryKeys + ']' + #13#10 + e.Message, EVENTLOG_WARNING_TYPE);
	hLog.Add('{now} ' + _('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');
	hLog.AddException(e);

  {$IFDEF DEBUG}
  hLog.Add(E.StackTrace);
  ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr);
//  raise TObject(AcquireExceptionObject);
  {$ENDIF}
end;

procedure TdmLiveMirrorRunner.ReplicateGenerators;
var
  slMirrorGenerators: TStringList;
begin
  if (FDMConfig.MasterDBType = 'Interbase') and (FDMConfig.MirrorDBType = 'Interbase') then
  begin
    qGenerators.Close;
    qGenerators.Connection := FDMConfig.MasterNode.Connection;
    qGenerators.Exec;

    slMirrorGenerators := TStringList.Create;
    try
      qMirrorGenerators.Close;
      qMirrorGenerators.Connection := FDMConfig.MirrorNode.Connection;
      qMirrorGenerators.Exec;
      while not qMirrorGenerators.Eof do
      begin
        slMirrorGenerators.Add(qMirrorGenerators.Field['gen_name'].AsString);
        qMirrorGenerators.Next;
      end;

      while not qGenerators.Eof do
      begin
        if slMirrorGenerators.IndexOf(qGenerators.Field['gen_name'].Value) >= 0 then
        begin
          qGetGenValue.Close;
          qGetGenValue.Connection := FDMConfig.MasterNode.Connection;
          qGetGenValue.Macro['gen_name'].Value := qGenerators.Field['gen_name'].Value;
          qGetGenValue.Exec;

          qSyncGenerator.Close;
          qSyncGenerator.Connection := FDMConfig.MirrorNode.Connection;
          qSyncGenerator.Macro['gen_name'].Value := qGenerators.Field['gen_name'].Value;
          qSyncGenerator.Macro['value'].Value := qGetGenValue.Field['val'].Value;
          qSyncGenerator.Exec;
        end;
        qGenerators.Next;
      end;
    finally
      slMirrorGenerators.Free;
    end;
  end;
end;

procedure TdmLiveMirrorRunner.ReplicatorReplicationResult(Sender: TObject);
begin
  ReplicateGenerators;

  if Replicator.ReplicateOnlyChangedFields then begin
    if (Replicator.LastResult.ResultType = rtReplicated) or (Replicator.LastResult.ResultType = rtNothingToReplicate) then begin
      if Replicator.LocalDB.InTransaction then
        Replicator.LocalDB.Commit;
      if Replicator.RemoteDB.InTransaction then
        Replicator.RemoteDB.Commit;
    end else begin
      if Replicator.LocalDB.InTransaction then
        Replicator.LocalDB.Rollback;
      if Replicator.RemoteDB.InTransaction then
        Replicator.RemoteDB.Rollback;
    end;
    Replicator.Disconnect;
  end;
end;

procedure TdmLiveMirrorRunner.ReplicatorRowReplicated(Sender: TObject;
  TableName: string; Fields: TCcMemoryFields; QueryType: TCcQueryType);
begin
//  LogMessage('Row replicated : Table ' + TableName + ' [' +  Replicator.Log.PrimaryKeys + ']', EVENTLOG_INFORMATION_TYPE);
  hLog.Add('{now} ' + _('Row replicated : Table : ') + TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');

  if not Replicator.ReplicateOnlyChangedFields then begin
    Replicator.LocalDB.CommitRetaining;
    Replicator.RemoteDB.CommitRetaining;
  end;
end;

function TdmLiveMirrorRunner.ConfigDatabases: Boolean;
var
  slTables: TStringList;
  I: Integer;
  slExcludedTables: TStringList;
begin
  Result := False;
 	hLog.Add(_('{now} Checking database configuration...'));
  FLiveMirrorService.LogMessage('Configuring databases for replication...', EVENTLOG_INFORMATION_TYPE);
  try
    FDMConfig.ConfigureNodes;
    FDMConfig.SaveConfig; //We save the config file so that the MetaDataCreated field gets set
    hLog.Add(_('{now} Databases configuration configured successfully!'));
    Result := True;
  except on E:Exception do
    begin
      hLog.Add(_('{now} Error setting up databases for replication!'));
      hLog.AddException(E);
      hLog.Add(E.StackTrace);
      ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr)
//      raise TObject(AcquireExceptionObject);
//      ExceptionManager.ShowLastExceptionData;
    end;
  end;
end;

procedure TdmLiveMirrorRunner.ServiceAfterInstall(Sender: TService);
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

procedure TdmLiveMirrorRunner.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  Replicator.AutoReplicate.Start;
end;

procedure TdmLiveMirrorRunner.ServiceDestroy(Sender: TObject);
begin
  FDMConfig.Free;
end;

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}
function TdmLiveMirrorRunner.CheckLiveMirrorLicence : Boolean;
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

procedure TdmLiveMirrorRunner.Initialize;
var
  iniConfigs: TIniFile;
  cPath: String;
  nReplFrequency: Integer;
  cErrorMessage: String;
begin
  try
    FDMConfig.LoadConfig(FDMConfig.ConfigName);
    cPath := GetLiveMirrorRoot + '\Configs\' + FDMConfig.ConfigName + '\log\';
    ForceDirectories(cPath);

    with hLog.hlWriter.hlFileDef do begin
      path := cPath;
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
//    hLog.Add(_('Replicating only changed fields :') + #9 + BoolToStr(FDMConfig.TrackChanges));
    hLog.Add('{/}{LNumOff}{*80*}');

    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
{    //Check licence and die if it's incorrect
    if not CheckLiveMirrorLicence then begin
      //Clear licence if it was incorrect
      LogMessage(Format(_('LiveMirror licence invalid for configuration %s.'#13#10'Clearing licence information from setup.'#13#10'Database will not be synchronized till licence is corrected.'), [FDMConfig.ConfigName]), EVENTLOG_ERROR_TYPE);
      FDMConfig.Licence := '';
      FDMConfig.SaveConfig;
      Abort;
    end;}
    {$ENDIF}
    {$ENDIF}

    //Create replication meta-data and triggers if they aren't there
    //Any new tables are automatically detected and triggers added
    if ConfigDatabases then begin
      Replicator.AutoReplicate.Frequency := FDMConfig.SyncFrequency;
      Replicator.AutoReplicate.Enabled := True;
      Replicator.Direction := sdLocalToRemote;
      Replicator.ReplicateOnlyChangedFields := (FDMConfig.MasterDBType = 'Interbase') and (FDMConfig.MasterNode.Connection.DBVersion = 'FB2.5');//FDMConfig.TrackChanges;
      Replicator.LocalNode.Connection := FDMConfig.MasterNode.Connection;
      Replicator.LocalNode.Name := 'MASTER';
      Replicator.RemoteNode.Connection := FDMConfig.MirrorNode.Connection;
      Replicator.RemoteNode.Name := 'MIRROR';

      hLog.Add(_('{now} Service ready!'));

      if not FRunOnce then
        Replicator.AutoReplicate.Start;
      Replicator.Replicate;
    end else begin
      cErrorMessage := _('{now} DATABASE CONFIGURATION FAILED - CONTACT COPYCAT TEAM FOR SUPPORT!');
      hLog.Add(cErrorMessage);
      FLiveMirrorService.LogMessage(cErrorMessage, EVENTLOG_ERROR_TYPE);
    end;
  except on E: Exception do begin
      FLiveMirrorService.LogMessage(E.Message, EVENTLOG_ERROR_TYPE);
      iniConfigs.Free;
    end;
  end;
end;

end.
