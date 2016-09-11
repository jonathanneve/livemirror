unit dLiveMirrorNode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  CcReplicator, CcConf, CcProviders, DB, dconfig, Vcl.SvcMgr,
  EExceptionManager, CcDB, main;

type
  TdmLiveMirrorNode = class(TDataModule)
    Replicator: TCcReplicator;
    qGenerators: TCcQuery;
    qSyncGenerator: TCcQuery;
    CcQuery1: TCcQuery;
    qGetGenValue: TCcQuery;
    qMirrorGenerators: TCcQuery;
    procedure ReplicatorLogLoaded(Sender: TObject);
    procedure ReplicatorException(Sender: TObject; e: Exception);
    procedure ReplicatorFinished(Sender: TObject);
    procedure ReplicatorEmptyLog(Sender: TObject);
    procedure ReplicatorConnectionLost(Sender: TObject;
      Database: TCcConnection);
    procedure ReplicatorReplicationAborted(Sender: TObject);
    procedure ReplicatorReplicationResult(Sender: TObject);
    procedure ReplicatorReplicationError(Sender: TObject; e: Exception;
      var CanContinue, SkipToRemote: Boolean);
    procedure ReplicatorRowReplicated(Sender: TObject; TableName: string;
      Fields: TCcMemoryFields; QueryType: TCcQueryType);
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure ReplicatorProgress(Sender: TObject);
  private
    FDMConfig: TdmConfig;
    FRunOnce: Boolean;
    FLiveMirrorService: TService;
    FLogFileName: string;
    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    function CheckLiveMirrorLicence : Boolean;
    {$ENDIF}
    {$ENDIF}

    function ConfigDatabases: Boolean;
    procedure ReplicateGenerators;
    procedure CreateNewLogFile;
    procedure WriteLog(line: String; timestamp: Boolean = True);overload;
    procedure WriteLog(sl: TStringList);overload;
    procedure WriteLog(E: Exception);overload;
  public
    LastReplicationTickCount: Int64;
    property LiveMirrorService: TService read FLiveMirrorService write FLiveMirrorService;
    property DMConfig: TdmConfig read FDMConfig;
    function Initialize(ConfigName: String): Boolean;
    procedure Run;
    { Déclarations publiques }
  end;

var
  dmLiveMirrorNode: TdmLiveMirrorNode;

implementation

{$R *.DFM}

uses LMUtils, IniFiles, dInterbase, Registry, gnugettext, IOUtils;

procedure TdmLiveMirrorNode.WriteLog(line: String; timestamp: Boolean);
begin
  if timestamp then
    line := '[' + FormatDateTime('hh:nn:ss', Now) + '] ' + line;

  TFile.AppendAllText(FLogFileName, line + #13#10, TEncoding.ANSI);
end;

procedure TdmLiveMirrorNode.WriteLog(E: Exception);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Add('•••••••••••••••••••••••');
    sl.Add('•••    E R R O R    •••' + E.Message);
    sl.Add('•••••••••••••••••••••••');
    WriteLog(sl);
  finally
    sl.Free;
  end;
end;

procedure TdmLiveMirrorNode.WriteLog(sl: TStringList);
var
  I: Integer;
begin
  for I := 0 to sl.Count-1 do
    WriteLog(sl[i], false);
end;

procedure TdmLiveMirrorNode.ReplicatorConnectionLost(Sender: TObject;
  Database: TCcConnection);
var
  dbNode: String;
begin
  if Database = Replicator.LocalDB then
    dbNode := Replicator.LocalNode.Name
  else
    dbNode := Replicator.RemoteNode.Name;

  WriteLog(Format(_('Connection lost to database : %s'), [dbNode]));
end;

procedure TdmLiveMirrorNode.ReplicatorEmptyLog(Sender: TObject);
begin
  if FRunOnce then
    WriteLog(_('Nothing to replicate'));
end;

procedure TdmLiveMirrorNode.ReplicatorException(Sender: TObject; e: Exception);
begin
  FLiveMirrorService.LogMessage(_('Replication failed with error : ') + #13#10 + e.Message, EVENTLOG_ERROR_TYPE);
	WriteLog(_('Replication failed with error : '));
	WriteLog(e);
  WriteLog(E.StackTrace, false);
  ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr)
end;

procedure TdmLiveMirrorNode.ReplicatorFinished(Sender: TObject);
begin
//  LogMessage('Replication finished : ' + #13#10 + 'Rows replicated : ' + IntToStr(Replicator.LastResult.RowsReplicated)
//  + #13#10 + 'Rows with errors : ' + IntToStr(Replicator.LastResult.RowsErrors)
//   , EVENTLOG_INFORMATION_TYPE);
  WriteLog(_('Replication finished : ') + #13#10 + _('Rows replicated : ') + IntToStr(Replicator.LastResult.RowsReplicated)
  + #13#10 + _('Rows with errors : ') + IntToStr(Replicator.LastResult.RowsErrors));
end;

procedure TdmLiveMirrorNode.ReplicatorLogLoaded(Sender: TObject);
begin
//  LogMessage('Starting replication : ' + IntToStr(Replicator.Log.LineCount) + ' rows to replicate...', EVENTLOG_INFORMATION_TYPE);
	WriteLog(_('Starting replication : '));// + IntToStr(Replicator.Log.LineCount) + _(' rows to replicate...'));
end;

procedure TdmLiveMirrorNode.ReplicatorProgress(Sender: TObject);
begin
  if (LiveMirrorService as TLiveMirror).LiveMirrorTerminating then
    Replicator.AbortReplication;
end;

procedure TdmLiveMirrorNode.ReplicatorReplicationAborted(Sender: TObject);
begin
  WriteLog('Replication aborted!');
end;

procedure TdmLiveMirrorNode.ReplicatorReplicationError(Sender: TObject; e: Exception;
  var CanContinue, SkipToRemote: Boolean);
begin
  FLiveMirrorService.LogMessage(_('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.PrimaryKeys + ']' + #13#10 + e.Message, EVENTLOG_WARNING_TYPE);
	WriteLog(_('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');
	WriteLog(e);

  {$IFDEF DEBUG}
  WriteLog(E.StackTrace, false);
  ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr);
//  raise TObject(AcquireExceptionObject);
  {$ENDIF}
end;

procedure TdmLiveMirrorNode.ReplicateGenerators;
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

procedure TdmLiveMirrorNode.ReplicatorReplicationResult(Sender: TObject);
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

procedure TdmLiveMirrorNode.ReplicatorRowReplicated(Sender: TObject;
  TableName: string; Fields: TCcMemoryFields; QueryType: TCcQueryType);
begin
//  LogMessage('Row replicated : Table ' + TableName + ' [' +  Replicator.Log.PrimaryKeys + ']', EVENTLOG_INFORMATION_TYPE);
  WriteLog(_('Row replicated : Table : ') + TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');

  if not Replicator.ReplicateOnlyChangedFields then begin
    Replicator.LocalDB.CommitRetaining;
    Replicator.RemoteDB.CommitRetaining;
  end;
end;

function TdmLiveMirrorNode.ConfigDatabases: Boolean;
var
  slTables: TStringList;
  I: Integer;
  slExcludedTables: TStringList;
begin
  Result := False;
 	WriteLog(_('Checking database configuration...'));
  FLiveMirrorService.LogMessage('Configuring databases for replication...', EVENTLOG_INFORMATION_TYPE);
  try
    FDMConfig.ConfigureNodes;
    FDMConfig.SaveConfig; //We save the config file so that the MetaDataCreated field gets set
    WriteLog(_('Databases configuration configured successfully!'));
    Result := True;
  except on E:Exception do
    begin
      WriteLog(_('Error setting up databases for replication!'));
      WriteLog(E);
      WriteLog(E.StackTrace, false);
      ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr)
//      raise TObject(AcquireExceptionObject);
//      ExceptionManager.ShowLastExceptionData;
    end;
  end;
end;

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}
function TdmLiveMirrorRunner.CheckLiveMirrorLicence : Boolean;
begin
  Result := False;
  if (FDMConfig.Licence <> '') then begin
     WriteLog(_('Checking licence information...'));
     try
       if not CheckLicenceActivation(FDMConfig.ConfigName, FDMConfig.Licence) then begin
         WriteLog(_('Error checking licence, please check your Internet connection'));
         Exit;
       end;
       Result := True;
     except
       on E: Exception do begin
         WriteLog(_('Licencing error : '));
         WriteLog(E.Message);
       end;
     end;
  end
  else
    WriteLog(_('No licence set for this database configuration. Synchronization aborting.'));
end;
{$ENDIF}
{$ENDIF}

procedure TdmLiveMirrorNode.DataModuleCreate(Sender: TObject);
begin
  FDMConfig := TdmConfig.Create(Self);
  LastReplicationTickCount := 0;
end;

procedure TdmLiveMirrorNode.DataModuleDestroy(Sender: TObject);
begin
  FDMConfig.Free;
end;

procedure TdmLiveMirrorNode.CreateNewLogFile;
var
  slHeader: TStringList;
  cPath: string;
begin
  cPath := GetLiveMirrorRoot + '\Configs\' + FDMConfig.ConfigName + '\log\';
  ForceDirectories(cPath);
  FLogFileName := cPath + '\' + FormatDateTime('yyyy-mm-dd hh.nn.ss', Now) + '.log';
  slHeader := TStringList.Create;
  try
    slHeader.Add('********************************************************************************');
    slHeader.Add('>>>> Initializing LiveMirror replication thread...');
    slHeader.Add('           ' + _('Version:') + LiveMirrorVersion);
    slHeader.Add('           ' + _('Configuration name: ') + FDMConfig.ConfigName);
    slHeader.Add('           ' + _('MASTER database :') + #9 + FDMConfig.MasterNode.Description);
    slHeader.Add('           ' + _('MIRROR database :') + #9 + FDMConfig.MirrorNode.Description);
    slHeader.Add('           ' + _('Replication frequency :') + #9 + IntToStr(FDMConfig.SyncFrequency) + _(' seconds'));
    slHeader.Add('********************************************************************************');
    WriteLog(slHeader);
  finally
    slHeader.Free;
  end;
end;

function TdmLiveMirrorNode.Initialize(ConfigName: String): Boolean;
var
  iniConfigs: TIniFile;
  cPath: String;
  nReplFrequency: Integer;
  cErrorMessage: String;
begin
  FDMConfig.ConfigName := ConfigName;

  try
    FDMConfig.LoadConfig(FDMConfig.ConfigName);
    CreateNewLogFile;

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
      //Replicator.AutoReplicate.Frequency := FDMConfig.SyncFrequency;
      //Replicator.AutoReplicate.Enabled := True;
      Replicator.Direction := sdLocalToRemote;
      Replicator.ReplicateOnlyChangedFields := (FDMConfig.MasterDBType = 'Interbase') and (FDMConfig.MasterNode.Connection.DBVersion = 'FB2.5');//FDMConfig.TrackChanges;
      Replicator.LocalNode.Connection := FDMConfig.MasterNode.Connection;
      Replicator.LocalNode.Name := 'MASTER';
      Replicator.RemoteNode.Connection := FDMConfig.MirrorNode.Connection;
      Replicator.RemoteNode.Name := 'MIRROR';

      WriteLog(_('Service ready!'));
      Result := True;
    end else begin
      cErrorMessage := _('DATABASE CONFIGURATION FAILED - CONTACT COPYCAT TEAM FOR SUPPORT!');
      WriteLog(cErrorMessage);
      FLiveMirrorService.LogMessage(cErrorMessage, EVENTLOG_ERROR_TYPE);
      Result := False;
    end;
  except on E: Exception do begin
      WriteLog(E.Message);
      FLiveMirrorService.LogMessage(E.Message, EVENTLOG_ERROR_TYPE);
      iniConfigs.Free;
      Result := False;
    end;
  end;
end;


procedure TdmLiveMirrorNode.Run;
begin
  if LMFileSize(FLogFileName) > 1000000 then
    CreateNewLogFile;

  Replicator.Replicate;
end;

end.
