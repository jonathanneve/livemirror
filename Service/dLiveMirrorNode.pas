unit dLiveMirrorNode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  CcReplicator, CcConf, CcProviders, DB, dconfig, Vcl.SvcMgr,
  EExceptionManager, CcDB, errors, Generics.Collections, smtpsend,
  FireDAC.UI.Intf, FireDAC.Stan.Async, FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Util, FireDAC.Stan.Intf, FireDAC.Comp.Script;

type
  TCcGeneralErrorRecord = class
    ErrorType : String;
    ErrorDB: String;
    Ongoing: Boolean;
    FirstOccurrence: TDateTime;
    LastOccurrence: TDateTime;
    ReportDateTime: TDateTime;
    Reported: Boolean;
    NumberOfCycles: Integer;
  end;

  TCcRowErrorRecord = class
    ErrorType : String;
    FirstOccurrence: TDateTime;
    LastOccurrence: TDateTime;
    ReportDateTime: TDateTime;
    Reported: Boolean;
    OccurredPrevCycle: Boolean;
    OccurredCurrCycle: Boolean;
  end;

  TCcRowErrorAction = (reaTryAgain, reaSkipAndContinueCycle, reaSkipAndAbortCycle);

  TdmLiveMirrorNode = class(TDataModule)
    Replicator: TCcReplicator;
    qGenerators: TCcQuery;
    qSyncGenerator: TCcQuery;
    CcQuery1: TCcQuery;
    qGetGenValue: TCcQuery;
    qMirrorGenerators: TCcQuery;
    FDScript: TFDScript;
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
    procedure ReplicatorConnectLocal(Sender: TObject);
    procedure ReplicatorBeforeReplicate(Sender: TObject);
    procedure ReplicatorConnectRemote(Sender: TObject);
    procedure ReplicatorRowReplicatingError(Sender: TObject; TableName: string;
      Fields: TCcMemoryFields; E: Exception; var Retry,
      ShouldAbortReplication: Boolean);
  private
    FDMConfig: TdmConfig;
    FRunOnce: Boolean;
    FLiveMirrorService: TService;
    FLogFileName: string;
    FLastConnectionErrorReport: TDateTime;
    FGeneralErrorReports: TDictionary<String, TCcGeneralErrorRecord>;
    FRowErrorReports: TDictionary<String, TCcRowErrorRecord>;

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
    function ErrorConfigByException(E: Exception): TCcErrorConfig;
    procedure ReportGeneralError(errorType: String; errorKey: String; exceptionMessage: String; forceReport: Boolean; errorDB: String = '');
    procedure ReportErrorRecovery(errorType, errorKey: String; database: String);
    procedure ResetGeneralErrors;
    function ReportRowError(errorType: String; tableName, primaryKeyValues: String; E: Exception): TCcRowErrorAction;
    procedure ResetRowErrors;
    procedure SendErrorReport(subject, destEmail: String; slEmailText: TStringList);
    procedure InsertErrorReportHeader(slEmailText: TStringList; errorDate: TDateTime; database: String; errorClassName: String = ''; tableName: String = ''; primaryKeyValues: String = '');
    procedure CheckSQLChanges;
  public
    LastReplicationTickCount: Int64;
    Initialized: Boolean;
    property LogFileName: String read FLogFileName;
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

uses LMUtils, IniFiles, dInterbase, Registry, gnugettext, IOUtils, FireDAC.Stan.Error,
  main, CcProvFireDAC;

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

procedure TdmLiveMirrorNode.ReportGeneralError(errorType: String; errorKey: String; exceptionMessage: String; forceReport: Boolean; errorDB: String);
var
  errorConf: TCcErrorConfig;
  lReport: Boolean;
  err: TCcGeneralErrorRecord;
  slEmailText: TStringList;
  errorTypeDisplay: string;
begin
  if (FLiveMirrorService as TLiveMirror).lRunOnce then
    Exit;

  errorConf := DMConfig.ErrorConfig.ErrorConfigs[errorType];
  if errorConf.ReportErrorToEmail <> '' then begin
    if FGeneralErrorReports.ContainsKey(errorType + errorKey) then
      err := FGeneralErrorReports[errorType + errorKey]
    else begin
      err := TCcGeneralErrorRecord.Create;
      err.ErrorType := errorType;
      err.ErrorDB := errorDB;
      err.FirstOccurrence := Now;
      err.LastOccurrence := Now;
      err.NumberOfCycles := 0;
      FGeneralErrorReports.Add(errorType + errorKey, err);
    end;

{    //Catastrophic errors (errors that occur outside replication, and that stop
    //the whole replication process) are systematically reported
    if forceReport then
      lReport := True
    else begin}
      //If the error hasn't been reported yet, then we should wait
      //at least TryAgainSeconds before reporting it, to give the
      //error time to fix itself
      if not err.Reported and ((((Now - err.FirstOccurrence) * (24 * 60 * 60)) < errorConf.TryAgainSeconds) or
           ((err.NumberOfCycles = 0) and errorConf.TryAgainNextCycle)) then
        lReport := false
      else
        lReport := (((Now - err.ReportDateTime) * 24 * 60) >= errorConf.ReportAgainMinutes);
//    end;

    err.Ongoing := True;
    if lReport then
    begin
      err.ReportDateTime := Now;
      err.Reported := True;

      slEmailText := TStringList.Create;
      try
        errorTypeDisplay := errorConf.ErrorTypeDisplay;
        slEmailText.Add(Format(_('A %s occurred while synchronizing your databases!'), [errorTypeDisplay]));
        InsertErrorReportHeader(slEmailText, err.LastOccurrence, errorDB);
        slEmailText.Add(exceptionMessage);
        SendErrorReport('[LiveMirror][' + FDMConfig.ConfigName + '] ' + errorTypeDisplay, errorConf.ReportErrorToEmail, slEmailText);
      finally
        slEmailText.Free;
      end;
    end;
  end;
end;

//Called when a row-level error occurs
//Returns the action that should be taken (retry or continue or abort)
function TdmLiveMirrorNode.ReportRowError(errorType: String; tableName, primaryKeyValues: String; E: Exception): TCcRowErrorAction;
var
  errorConf: TCcErrorConfig;
  lReport: Boolean;
  err: TCcRowErrorRecord;
  errorKey: String;
  slEmailText: TStringList;
  errorTypeDisplay: string;
begin
  if (LiveMirrorService as TLiveMirror).lRunOnce then begin
    Result := reaSkipAndContinueCycle;
    Exit;
  end;

  errorKey := tableName + '|' + primaryKeyValues;
  errorConf := DMConfig.ErrorConfig.ErrorConfigs[errorType];
  if errorConf.ReportErrorToEmail <> '' then begin
    if FRowErrorReports.ContainsKey(errorType + errorKey) then
      err := FRowErrorReports[errorType + errorKey]
    else begin
      err := TCcRowErrorRecord.Create;
      err.ErrorType := errorType;
      err.FirstOccurrence := Now;
      err.LastOccurrence := Now;
      FRowErrorReports.Add(errorType + errorKey, err);
    end;

    //If this error is occuring for the first time, we should wait
    //TryAgainSeconds and try to replicate the row again
    if (errorConf.TryAgainSeconds > 0) and (((Now - err.LastOccurrence) * (24 * 60 * 60)) < errorConf.TryAgainSeconds) then begin
      Sleep(1000 * errorConf.TryAgainSeconds);
      Result := reaTryAgain;
      Exit;
    end;

    if errorConf.CanContinueReplCycle then
      Result := reaSkipAndContinueCycle
    else
      Result := reaSkipAndAbortCycle;

    // The TryAgainNextCycle option means that we should wait for the following
    //cycle before reporting the error.
    //If we've already waited, we should report it now
    if (errorConf.TryAgainNextCycle) and (not err.OccurredPrevCycle) then
      lReport := false
    else
      lReport := true;

    err.OccurredCurrCycle := True;
    if lReport then
    begin
      err.ReportDateTime := Now;
      err.Reported := True;

      slEmailText := TStringList.Create;
      try
        errorTypeDisplay := errorConf.ErrorTypeDisplay;
        slEmailText.Add(Format(_('A %s occurred while synchronizing your databases!'), [errorTypeDisplay]));
        InsertErrorReportHeader(slEmailText, err.LastOccurrence, '', E.ClassName, tableName, primaryKeyValues);
        slEmailText.Add(E.Message);
        SendErrorReport('[LiveMirror][' + FDMConfig.ConfigName + '] ' + errorTypeDisplay, errorConf.ReportErrorToEmail, slEmailText);
      finally
        slEmailText.Free;
      end;
    end;
  end;
end;

procedure TdmLiveMirrorNode.InsertErrorReportHeader(slEmailText: TStringList; errorDate: TDateTime; database: String; errorClassName: String; tableName, primaryKeyValues: String);
begin
  slEmailText.Add('');
  slEmailText.Add('****************************************');
  slEmailText.Add(_('MASTER database:') + #9 + FDMConfig.MasterNode.Description);
  slEmailText.Add(_('MIRROR database:') + #9 + FDMConfig.MirrorNode.Description);
  slEmailText.Add(_('Error date:') + #9 + FormatDateTime('yyyy-mm-dd hh:nn:ss', errorDate));
  if errorClassName <> '' then
    slEmailText.Add(_('Error type:') + #9 + errorClassName);
  if database <> '' then
    slEmailText.Add(_('Database:') + #9 + database);
  if tableName <> '' then
  begin
    slEmailText.Add(_('Table name:') + #9 + tableName);
    slEmailText.Add(_('Row:') + #9 + primaryKeyValues);
  end;
  slEmailText.Add('****************************************');
  slEmailText.Add('');
end;

procedure TdmLiveMirrorNode.SendErrorReport(subject, destEmail: String; slEmailText: TStringList);
begin
  WriteLog(Format(_('Sending error report by email to: %s...'), [destEmail]));
  try
    SendToEx('contact@copycat.fr', destEmail, subject, 'webmail.copycat.fr', slEmailText, 'jonathan@copycat.fr', 'nahtanoj');
  except on E: Exception do begin
    FLiveMirrorService.LogMessage(_('An error occurred while sending error report:') + #13#10 + e.Message, EVENTLOG_ERROR_TYPE);
    WriteLog(_('An error occurred while sending error report:'));
    WriteLog(e);
    WriteLog(E.StackTrace, false);
    ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr);
  end;
  end;
end;

procedure TdmLiveMirrorNode.ReplicatorBeforeReplicate(Sender: TObject);
var
  key: String;
begin
  for key in FGeneralErrorReports.Keys do begin
    with FGeneralErrorReports[key] do begin
      if Ongoing then
        NumberOfCycles := NumberOfCycles + 1;
    end;
  end;
end;

procedure TdmLiveMirrorNode.ReplicatorConnectionLost(Sender: TObject;
  Database: TCcConnection);
var
  dbNode: String;
  errorConf: TCcErrorConfig;
  lReport: Boolean;
  err: string;
begin
  if Database = Replicator.LocalDB then begin
    dbNode := Replicator.LocalNode.Name;
  end
  else begin
    dbNode := Replicator.RemoteNode.Name;
  end;

  WriteLog(Format(_('Connection lost to database : %s'), [dbNode]));
end;

procedure TdmLiveMirrorNode.ReplicatorConnectLocal(Sender: TObject);
begin
  ReportErrorRecovery(CONNECTION_ERROR, CONNECTION_ERROR + 'LOCAL', _('MASTER'));
end;

procedure TdmLiveMirrorNode.ReplicatorConnectRemote(Sender: TObject);
begin
  ReportErrorRecovery(CONNECTION_ERROR, CONNECTION_ERROR + 'REMOTE', _('MIRROR'));
end;

procedure TdmLiveMirrorNode.ReportErrorRecovery(errorType, errorKey: String; database: String);
var
  err: TCcGeneralErrorRecord;
  errorConfig: TCcErrorConfig;
  slEmailText: TStringList;
  errorTypeDisplay: String;
begin
  if (LiveMirrorService as TLiveMirror).lRunOnce then
    Exit;

  if FGeneralErrorReports.ContainsKey(errorType + errorKey) then
  begin
    err := FGeneralErrorReports[errorType + errorKey];
    errorConfig := DMConfig.ErrorConfig.ErrorConfigs[errorType];
    if err.Ongoing and errorConfig.ReportWhenResolved then
    begin
      slEmailText := TStringList.Create;
      try
        errorTypeDisplay := errorConfig.ErrorTypeDisplay;
        slEmailText.Add(Format(_('%s resolved: database synchronization has resumed.'), [errorTypeDisplay]));
        InsertErrorReportHeader(slEmailText, err.LastOccurrence, database);
        SendErrorReport('[LiveMirror][' + FDMConfig.ConfigName + '] ' + Format(_('% resolved'), [errorTypeDisplay]), errorConfig.ReportErrorToEmail, slEmailText);
      finally
        slEmailText.Free;
      end;
    end;

    //Reset the error record in the the list so that the error is no longer
    //considered current and can be reported again
    //We don't initially remove it from the list, so as to make sure that
    //it can't get reported again too frequently
    err.NumberOfCycles := 0;
    err.Ongoing := False;

    //If it last occured more than ReportAgainMinutes minutes ago, we can remove
    //the error from the list
    //If the same error occurs again, it will get treated as a new error
    //(including optionally not reporting it till a number of cycles or seconds)
    if ((Now - err.LastOccurrence) * 24 * 60) > errorConfig.ReportAgainMinutes then
      FGeneralErrorReports.Remove(errorType + errorKey);
  end;
end;

procedure TdmLiveMirrorNode.ReplicatorEmptyLog(Sender: TObject);
begin
  if FRunOnce then
    WriteLog(_('Nothing to replicate'));
end;

procedure TdmLiveMirrorNode.ReplicatorException(Sender: TObject; e: Exception);
var
  errorConf: TCcErrorConfig;
begin
  FLiveMirrorService.LogMessage(_('Replication failed with error : ') + #13#10 + e.Message, EVENTLOG_ERROR_TYPE);
	WriteLog(_('Replication failed with error : '));
	WriteLog(e);
  WriteLog(E.StackTrace, false);
  ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr);
end;

procedure TdmLiveMirrorNode.ReplicatorFinished(Sender: TObject);
begin
//  LogMessage('Replication finished : ' + #13#10 + 'Rows replicated : ' + IntToStr(Replicator.LastResult.RowsReplicated)
//  + #13#10 + 'Rows with errors : ' + IntToStr(Replicator.LastResult.RowsErrors)
//   , EVENTLOG_INFORMATION_TYPE);

end;

procedure TdmLiveMirrorNode.ReplicatorLogLoaded(Sender: TObject);
begin
//  LogMessage('Starting replication : ' + IntToStr(Replicator.Log.LineCount) + ' rows to replicate...', EVENTLOG_INFORMATION_TYPE);
  ReportErrorRecovery(OTHER_ERROR, 'SERVICE_INIT_ERROR', '');
	WriteLog(_('Starting replication : '));// + IntToStr(Replicator.Log.LineCount) + _(' rows to replicate...'));
end;

procedure TdmLiveMirrorNode.ReplicatorProgress(Sender: TObject);
begin
  if (LiveMirrorService as TLiveMirror).LiveMirrorTerminating then begin
    WriteLog('Replication service aborting...');
    Replicator.AbortReplication;
  end;
end;

procedure TdmLiveMirrorNode.ReplicatorReplicationAborted(Sender: TObject);
begin
  WriteLog(_('Replication aborted!'));
end;

procedure TdmLiveMirrorNode.ReplicatorReplicationError(Sender: TObject; e: Exception;
  var CanContinue, SkipToRemote: Boolean);
begin
  FLiveMirrorService.LogMessage(_('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.PrimaryKeys + ']' + #13#10 + e.Message, EVENTLOG_WARNING_TYPE);
	WriteLog(_('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');
	WriteLog(e);

  WriteLog(E.StackTrace, false);
  ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr);
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
      if FDMConfig.MirrorNode.Connection.InTransaction then
        FDMConfig.MirrorNode.Connection.Commit;
      slMirrorGenerators.Free;
    end;
  end;
end;

procedure TdmLiveMirrorNode.ResetGeneralErrors;
var
  key: String;
begin
  //This function sets all the general errors (not connection losses)
  //to inactive so that if ever they occur again, they will be considered
  //fresh errors and reported (or not) accordingly
  for key in FGeneralErrorReports.Keys do begin
    if FGeneralErrorReports[key].ErrorType = OTHER_ERROR then
      ReportErrorRecovery(FGeneralErrorReports[key].ErrorType, key, FGeneralErrorReports[key].ErrorDB);
  end;
end;

//This function removes all the row-level errors that didn't occur during this cycle
//and resets those that did occur to OccurredPrevCycle, to prepare for next cycle
procedure TdmLiveMirrorNode.ResetRowErrors;
var
  key: String;
begin
  for key in FRowErrorReports.Keys do begin
    if FRowErrorReports[key].OccurredCurrCycle then begin
      FRowErrorReports[key].OccurredPrevCycle := True;
      FRowErrorReports[key].OccurredCurrCycle := False;
    end
    else
      FRowErrorReports.Remove(key);
  end;
end;

procedure TdmLiveMirrorNode.ReplicatorReplicationResult(Sender: TObject);
var
  rt: TCcReplicationResultType;
begin
  rt := Replicator.LastResult.ResultType;

  Assert(rt <> rtNone);

  if (rt = rtReplicatorBusy) or (rt = rtNothingToReplicate) then
    Exit;

  if rt = rtErrorConnectLocal then
    ReportGeneralError(CONNECTION_ERROR, 'LOCAL', Replicator.LastResult.ExceptionMessage, False, _('MASTER'))
  else if rt = rtErrorConnectRemote then
    ReportGeneralError(CONNECTION_ERROR, 'REMOTE', Replicator.LastResult.ExceptionMessage, False, _('MIRROR'))
  else if (rt = rtException) or (rt = rtErrorCheckingConflicts) or (rt = rtErrorLoadingLog) then
    ReportGeneralError(OTHER_ERROR, Replicator.LastResult.ExceptionMessage, Replicator.LastResult.ExceptionMessage, False)
  else begin
    ResetGeneralErrors;

    if Replicator.ReplicateOnlyChangedFields then begin
      if Replicator.LocalDB.InTransaction then
        Replicator.LocalDB.Commit;
      if Replicator.RemoteDB.InTransaction then
        Replicator.RemoteDB.Commit;
    end;
    ReplicateGenerators;
  end;

  ResetRowErrors;

  //If transactions and connection are still open, rollback and disconnect
  if Replicator.LocalDB.InTransaction then
    Replicator.LocalDB.Rollback;
  if Replicator.RemoteDB.InTransaction then
    Replicator.RemoteDB.Rollback;
  Replicator.Disconnect;

  WriteLog(_('Replication finished : ') + #13#10 + _('Rows replicated : ') + IntToStr(Replicator.LastResult.RowsReplicated)
  + #13#10 + _('Rows with errors : ') + IntToStr(Replicator.LastResult.RowsErrors));
  WriteLog('****************************************'#13#10);
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

procedure TdmLiveMirrorNode.ReplicatorRowReplicatingError(Sender: TObject;
  TableName: string; Fields: TCcMemoryFields; E: Exception; var Retry,
  ShouldAbortReplication: Boolean);
var
  errorConf: TCcErrorConfig;
  action: TCcRowErrorAction;
begin
  errorConf := ErrorConfigByException(E);
  action := ReportRowError(errorConf.ErrorType, TableName, Replicator.Log.PrimaryKeys, E);
  if action = reaTryAgain then begin
    Retry := True;
    WriteLog(_('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');
   	WriteLog(e);
    WriteLog(_('Trying again... '#13#10));
  end
  else if action = reaSkipAndAbortCycle then
    ShouldAbortReplication := True;
end;

function TdmLiveMirrorNode.ErrorConfigByException(E: Exception): TCcErrorConfig;
var
  err: EFDDBEngineException;
begin
  err := E as EFDDBEngineException;
  if err.Kind = ekRecordLocked then
    Result := DMConfig.ErrorConfig.ErrorConfigs[LOCK_VIOLATION]
  else if err.Kind = ekFKViolated then
    Result := DMConfig.ErrorConfig.ErrorConfigs[FK_VIOLATION]
  else
    Result := DMConfig.ErrorConfig.ErrorConfigs[OTHER_ROW_ERROR];
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
      ExceptionManager.StandardEurekaNotify(ExceptObject,ExceptAddr);
      ReportGeneralError(OTHER_ERROR, 'SERVICE_INIT_ERROR', e.Message, True);
      Result := False;
//      raise TObject(AcquireExceptionObject);
//      ExceptionManager.ShowLastExceptionData;
    end;
  end;
end;

{$IFNDEF LM_EVALUATION}
{$IFNDEF DEBUG}
function TdmLiveMirrorNode.CheckLiveMirrorLicence : Boolean;
begin
  Result := False;
  if (FDMConfig.Licence <> '') then
  begin
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
  Initialized := False;
  FDMConfig := TdmConfig.Create(Self);
  LastReplicationTickCount := 0;

  FGeneralErrorReports := TDictionary<String, TCcGeneralErrorRecord>.Create;
  FRowErrorReports := TDictionary<String, TCcRowErrorRecord>.Create;
end;

procedure TdmLiveMirrorNode.DataModuleDestroy(Sender: TObject);
var
  key: String;
begin
  for key in FGeneralErrorReports.Keys do
    FGeneralErrorReports[key].Free;
  for key in FRowErrorReports.Keys do
    FRowErrorReports[key].Free;
  FGeneralErrorReports.Free;
  FRowErrorReports.Free;

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
    slHeader.Add(_('Initializing LiveMirror replication thread...') + #9 + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
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

procedure TdmLiveMirrorNode.CheckSQLChanges;
var
  cPath: string;
  cErrorMessage: String;
  cCurrentStatement: string;
begin
  cPath := GetLiveMirrorRoot + '\Configs\' + FDMConfig.ConfigName;
  if FileExists(cPath + '\sql.txt') then begin
    FDScript.Connection := (FDMConfig.MirrorNode.Connection as TCcConnectionFireDAC).FDConnection;
    FDScript.Connection.Connected := True;
    FDScript.ScriptOptions.SpoolFileName := cPath + '\sql.log';
    FDScript.ScriptOptions.SpoolOutput := smOnReset;
    FDScript.ExecuteFile(cPath + '\sql.txt');
    FDScript.Connection.Connected := False;
{    try
      FDScript.SQLScripts.Clear;
      FDScript.SQLScriptFileName := cPath + '\sql.txt';

      FDScript.ValidateAll;
      if FDScript.Status = ssFinishSuccess then
        FDScript.ExecuteAll;



    except on E: Exception do begin
      cErrorMessage := _('ERROR APPLYING SQL UPDATE SCRIPT!' + #13#10 + 'Statement: ' + cCurrentStatement + #13#10 + 'Error: ' + E.Message +  #13#10 + 'RENAMING SCRIPT AND CONTINUING REPLICATION...');
      WriteLog(cErrorMessage);
      FLiveMirrorService.LogMessage(cErrorMessage, EVENTLOG_ERROR_TYPE);
      end;
    end;}
    if FDScript.Status = ssFinishSuccess then begin
      if FileExists(cPath + '\sql.old') then
        DeleteFile(cPath + '\sql.old');
      RenameFile(cPath + '\sql.txt', cPath + '\sql.old')
    end;
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
    //Check licence and die if it's incorrect
    if not CheckLiveMirrorLicence then begin
      //Clear licence if it was incorrect
      (LiveMirrorService as TLiveMirror).LogMessage(Format(_('LiveMirror licence invalid for configuration %s.'#13#10'Clearing licence information from setup.'#13#10'Database will not be synchronized till licence is corrected.'), [FDMConfig.ConfigName]), EVENTLOG_ERROR_TYPE);
      FDMConfig.Licence := '';
      FDMConfig.SaveConfig;
      Abort;
    end;
    {$ENDIF}
    {$ENDIF}

    CheckSQLChanges;

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
      ReportGeneralError(OTHER_ERROR, 'SERVICE_INIT_ERROR', e.Message, True);
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
