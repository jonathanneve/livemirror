unit dLogsAndSettings;

interface

uses
	SysUtils, Classes, CcConf, CcDB, DB, CcMemDS, CcConfStorage, CcRplList,
	RzCommon, CcConnADO, CcProviders, CcProvFIBPlus, FIBDatabase,
	pFIBDatabase, FIBDataSet, pFIBDataSet, FIBQuery, pFIBQuery, CcReplicator,
	LiveMirrorInterfaces, pFIBStoredProc, IniFiles;

type
	TReplicationAction = (raNone, raIncOK, raIncError);

	TdmLogsAndSettings = class(TDataModule, ISettingsModel)
		CcReplicatorList: TCcReplicatorList;
		CcConfigStorage: TCcConfigStorage;
		CcDataSet1: TCcDataSet;
		CcConfig: TCcConfig;
		CcConfigStorageDS: TDataSource;
		FrameController: TRzFrameController;
    dbLog: TpFIBDatabase;
    trLog: TpFIBTransaction;
    qRPLTables: TCcQuery;
    qInsertAlias: TpFIBStoredProc;
    qInsertUser: TCcQuery;
    qUser: TCcQuery;
    qFindAlias: TpFIBQuery;
    qInsertLog: TpFIBStoredProc;
    qDeleteAlias: TpFIBStoredProc;
    qUpdateLog: TpFIBStoredProc;
    qInsertLogError: TpFIBStoredProc;
		procedure DataModuleCreate(Sender: TObject);
		procedure DataModuleDestroy(Sender: TObject);
		procedure CcReplicatorListException(Sender: TObject; e: Exception);
		procedure CcReplicatorListLogLoaded(Sender: TObject);
		procedure CcReplicatorListReplicationError(Sender: TObject; e: Exception; var CanContinue: Boolean);
		procedure CcReplicatorListRowReplicated(Sender: TObject);
		procedure CcReplicatorListEmptyLog(Sender: TObject);
		procedure CcReplicatorListFinished(Sender: TObject);
		procedure DoConvertMessage(Sender: TField; var Text: String; DisplayText: Boolean);
		procedure DoConvertDateTimeAsLocalSettings(Sender: TField; var Text: String; DisplayText: Boolean);
	private
		{ Private declarations }
		FFormatSettings: TFormatSettings;
		FLogLinks: THashedStringList;
		FOnEndSync: TNotifyEvent;
		FOnRefreshLog: TRefreshLogEvent;
		FOnRefreshLogError: TRefreshLogErrorEvent;

		procedure AddLog(const Alias: string);
		procedure AddUser(const Value: string);
		procedure Append();
		procedure DeleteAlias(var ErrorMessage: string);
		function DoDeleteSettings(const IsRemoveTriggers: boolean): string;
		procedure DoCancelSettings();
		function DoRefreshSettings(): string;
		procedure DoReplicate();
		function DoSaveSettings(lNew: Boolean): string;
		procedure EditSettings(const Value: integer);
		procedure GenerateMissingTriggers(AConnection: TCcConnection);
		function GetIsUserExist(const UserName: string): boolean;
		function GetLocalDB(): TCcConnectionConfig;
		function GetLogID(const Alias: string): integer; overload;
		function GetLogID(AReplicator: TccReplicator): integer; overload;
		function GetOnEndSync(): TNotifyEvent;
		function GetOnRefreshLog(): TRefreshLogEvent;
		function GetOnRefreshLogError(): TRefreshLogErrorEvent;
		function GetRemoteDB(): TCcConnectionConfig;
//		function GetSelectedConfigID(): integer;
		function GetStoredConfigID(): integer;
		procedure InsertAlias();
		function InsertLog(const cConfigName: String): integer;
		procedure InsertLogError(cConfigName: String; const LogID: integer; const TableName: string; const PrimaryKeys: string; const ErrorMessage: string);
		procedure RemoveTriggers(AConnection: TCcConnection);
		procedure SaveSettings;
		procedure SetOnEndSync(const Value: TNotifyEvent);
		procedure SetOnRefreshLog(const Value: TRefreshLogEvent);
		procedure SetOnRefreshLogError(const Value: TRefreshLogErrorEvent);
		procedure StartAutoReplication();
		procedure StartStopAutoReplication(const IsStartRequest: boolean);
		procedure StopAutoReplication();
		procedure StopCurrentAutoReplication();
		procedure StartCurrentAutoReplication();
		procedure UpdateLog(cConfigName: String; const LogID: integer; const ReplicationAction: TReplicationAction; const IsTransferTerminated: boolean);
    function AliasExists(const Name: string): Boolean;
    procedure TryConfigConnect(conn: TCcConnection; databaseDescription: String);
	public
	end;

var
	dmLogsAndSettings: TdmLogsAndSettings;

implementation

uses
	Forms, Controls,
	FIB, StrUtils, Windows;

const
	CONFIG_FILENAME = 'config.ini';

{$R *.dfm}

{ TdmLogsAndSettings }

function TdmLogsAndSettings.GetOnEndSync(): TNotifyEvent;
begin
	Result := FOnEndSync;
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.SetOnEndSync(const Value: TNotifyEvent);
begin
	FOnEndSync := Value;
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.DataModuleCreate(Sender: TObject);
begin
	// initialize application
	GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FFormatSettings);

	FLogLinks := THashedStringList.Create();
	FLogLinks.Sorted := true;
	FLogLinks.Duplicates := dupError;

	CcConfigStorage.Path := ExtractFilePath(Application.ExeName) + CONFIG_FILENAME;
	CcConfigStorage.Open();
	dbLog.DBName := ExtractFilePath(Application.ExeName) + 'log.fdb';
  dbLog.LibraryName := 'fbembed.dll';
	dbLog.Connected := True;
	StartAutoReplication();
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.DataModuleDestroy(Sender: TObject);
begin
	StopAutoReplication();
	CcConfig.Disconnect();
	dbLog.Close();
	FreeAndNil(FLogLinks);
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.GenerateMissingTriggers(AConnection: TCcConnection);
var
	TableName: string;
begin
	try
		qRPLTables.Close();
		qRPLTables.Connection := AConnection;
		qRPLTables.Exec();
		while (not qRPLTables.Eof) do begin
			TableName := Trim(qRPLTables.FieldByIndex[0].AsString);
			if (not AnsiContainsStr(TableName, 'RPL$')) then
				CcConfig.GenerateTriggers(TableName);
			qRPLTables.Next();
		end;
	finally
		qRPLTables.Connection.CommitRetaining();
	end;
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.AddUser(const Value: string);
begin
	if (not GetIsUserExist(Value)) then begin
		try
			qInsertUser.Close();
			qInsertUser.Connection := CcConfigStorage.LocalDB.Connection;
			qInsertUser.Prepare();
			qInsertUser.Param['ALIAS_NAME'].AsString := UpperCase(Value);
			qInsertUser.Exec();
		finally
			qInsertUser.Connection.CommitRetaining();
		end;
	end;
end;
//-----------------------------------------------------------------------------

function TdmLogsAndSettings.GetLocalDB(): TCcConnectionConfig;
begin
	Result := CcConfigStorage.LocalDB;
end;
//-----------------------------------------------------------------------------
function TdmLogsAndSettings.GetRemoteDB(): TCcConnectionConfig;
begin
	Result := CcConfigStorage.RemoteDB;
end;
//-----------------------------------------------------------------------------
function TdmLogsAndSettings.DoSaveSettings(lNew: Boolean): string;
var
	ConfigName: string;
begin
	ConfigName := CcConfigStorage.FieldByName('ConfigName').AsString;
	if (ConfigName = '') then
		Application.MessageBox('Cannot save settings: alias is empty!', 'Error', MB_ICONERROR + MB_OK)
	else if lNew and not AliasExists(ConfigName) then
		Application.MessageBox(PChar('Alias ''' + ConfigName + ''' already exists!'), 'Error', MB_ICONERROR + MB_OK)
  else
		SaveSettings;
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.TryConfigConnect(conn: TCcConnection; databaseDescription: String);
begin
  CcConfig.Connection := conn;
  try
    CcConfig.Connect();
  except
    on E: Exception do begin
      raise Exception.Create('Cannot connect to ' + databaseDescription + ':' + #13#10 + E.Message);
    end;
  end;
end;

procedure TdmLogsAndSettings.SaveSettings;
var
	RemoteNodeName: string;
begin
  Screen.Cursor := crHourGlass;
  try
    RemoteNodeName := UpperCase(CcConfigStorage.FieldByName('ConfigName').AsString);
    //Connect to mirror database to validate conneciton params and to create RPL$ tables
    TryConfigConnect(CcConfigStorage.RemoteDB.Connection, 'mirror database');

    //Connect to master database to validate connection params and to create triggers and replication objects
    TryConfigConnect(CcConfigStorage.LocalDB.Connection, 'master database');

    try
      CcConfigStorage.Edit;
      CcConfigStorage.FieldByName('LocalNodeName').AsString := 'MASTER';
      CcConfigStorage.FieldByName('RemoteNodeName').AsString := RemoteNodeName;
      CcConfigStorage.FieldByName('ReplicationMode').AsString := 'BIDI';
      GenerateMissingTriggers(CcConfig.Connection);
      AddUser(RemoteNodeName);
    finally
      if CcConfigStorage.LocalDB.Connection.Connected then
        CcConfigStorage.LocalDB.Connection.Disconnect;
      if CcConfigStorage.RemoteDB.Connection.Connected then
        CcConfigStorage.RemoteDB.Connection.Disconnect;
    end;

    if CcConfigStorage.State <> dsBrowse then
      CcConfigStorage.Post;

    InsertAlias();

    CcReplicatorList.CurrentReplicator.AutoReplicate.Start();
    if (Assigned(FOnEndSync)) then
      FOnEndSync(Self);
  finally
    Screen.Cursor := crDefault;
  end;
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.Append();
begin
	CcConfigStorage.Append();
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.DoCancelSettings();
begin
  if CcConfigStorage.State <> dsBrowse then
    CcConfigStorage.Cancel();
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.InsertAlias();
var
	AliasName: string;
begin
	AliasName := UpperCase(CcConfigStorage.FieldValues['ConfigName']);
	if not AliasExists(AliasName) then
		try
      qInsertAlias.Close;
			qInsertAlias.ParamByName('CONFIG_NAME').AsString := AliasName;
			qInsertAlias.ExecQuery;
			trLog.CommitRetaining();
		except
			on E: Exception do begin
				trLog.RollbackRetaining;
				raise E;
			end;
		end;
end;
//-----------------------------------------------------------------------------

function TdmLogsAndSettings.GetStoredConfigID(): integer;
begin
	Result := CcConfigStorage.ConfigID;
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.EditSettings(const Value: integer);
var
	aReplicator: TCcReplicator;
begin
	CcConfigStorage.ConfigID := Value;
	CcConfigStorage.Edit();
	aReplicator := CcReplicatorList.CurrentReplicator;
	if (Assigned(aReplicator)) then
		aReplicator.AutoReplicate.Stop();
end;
//-----------------------------------------------------------------------------
function TdmLogsAndSettings.AliasExists(const Name: string): Boolean;
begin
  qFindAlias.Close;
	qFindAlias.ParamByName('config_name').AsString := UpperCase(Name);
  qFindAlias.ExecQuery;
  Result := qFindAlias.RecordCount > 0;
end;
//-----------------------------------------------------------------------------
function TdmLogsAndSettings.GetIsUserExist(const UserName: string): boolean;
var
	Value: boolean;
begin
	try
		Value := false;
		qUser.Close();
		qUser.Connection := CcConfigStorage.LocalDB.Connection;
		qUser.Prepare();
		qUser.Param['USER_NAME'].AsString := UpperCase(UserName);
		qUser.Exec();
		Value := not qUser.Eof;
	finally
		qUser.Connection.CommitRetaining();
	end;
	Result := Value;
end;
//----------------------------------------------------------------------------
function TdmLogsAndSettings.DoRefreshSettings(): string;
var
	ErrorMessage: string;
begin
	CcConfigStorage.Edit();
	SaveSettings;
	if (ErrorMessage <> '') then
		ErrorMessage := Format('Unable to refresh database configuration !%s%s', [#13#10#13#10, ErrorMessage]);
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.CcReplicatorListLogLoaded(Sender: TObject);
var
	aReplicator: TCcReplicator;
	Alias: string;
begin
	aReplicator := Sender as TCcReplicator;
	if (Assigned(aReplicator)) then begin
		Alias := aReplicator.Log.Dest.Name;
		AddLog(Alias);
	end;
end;
//----------------------------------------------------------------------------
function TdmLogsAndSettings.InsertLog(const cConfigName: String): integer;
var
	aField: TFIBXSQLVAR;
	Value: integer;
begin
	try
    Result := dbLog.Gen_Id('GEN_LOG_ID', 1, trLog);
		qInsertLog.Close;
		qInsertLog.ParamByName('LOG_ID').Value := Result;
		qInsertLog.ParamByName('CONFIG_NAME').Value := cConfigName;
		qInsertLog.ExecQuery;
		trLog.CommitRetaining;
	except
		on E: Exception do begin
			trLog.RollbackRetaining;
			raise E;
		end;
	end;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.UpdateLog(cConfigName: String; const LogID: integer; const ReplicationAction: TReplicationAction; const IsTransferTerminated: boolean);
var
	aField: TFIBXSQLVAR;
begin
	try
    qUpdateLog.Close;
		qUpdateLog.ParamByName('LOG_ID').Value := LogID;
		qUpdateLog.ParamByName('INC_RECORDS_OK').Value := ord(ReplicationAction = raIncOK);
		qUpdateLog.ParamByName('INC_RECORDS_ERROR').Value := ord(ReplicationAction = raIncError);
		qUpdateLog.ParamByName('TRANSFER_STATUS').Value := ord(IsTransferTerminated);
		qUpdateLog.ExecQuery;
		trLog.CommitRetaining;

    if Assigned(FOnRefreshLog) then
      FOnRefreshLog(cConfigName);
	except
		on E: Exception do begin
			trLog.RollbackRetaining();
			raise E;
		end;
	end;
end;
//----------------------------------------------------------------------------
function TdmLogsAndSettings.DoDeleteSettings(const IsRemoveTriggers: boolean): string;
var
	ErrorMessage: string;
	aReplicator: TCcReplicator;
begin
	aReplicator := CcReplicatorList.Replicators[CcConfigStorage.ConfigID];
	if (Assigned(aReplicator)) then
	begin
		aReplicator.AutoReplicate.Stop();
		if (IsRemoveTriggers) then begin
			RemoveTriggers(CcConfigStorage.LocalDB.Connection);
			RemoveTriggers(CcConfigStorage.RemoteDB.Connection);
		end;
		DeleteAlias(ErrorMessage);
		if (ErrorMessage <> '') then
			ErrorMessage := Format('Unable to delete configuration !%s%s', [#13#10#13#10, ErrorMessage]);

		CcConfigStorage.Delete;

		if (Assigned(FOnEndSync)) then
			FOnEndSync(Self);
	end;
	Result := ErrorMessage;
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.DeleteAlias(var ErrorMessage: string);
begin
	try
		qDeleteAlias.Close;
		qDeleteAlias.ParamByName('CONFIG_NAME').Value := CcConfigStorage.FieldByName('ConfigName').Value;
    qDeleteAlias.ExecQuery;
    trLog.CommitRetaining;
	except
		on E: Exception do begin
			ErrorMessage := E.Message;
		end;
	end;
end;
//----------------------------------------------------------------------------
//function TdmLogsAndSettings.GetSelectedConfigID(): integer;
//var
//	aField: TField;
//	Value: integer;
//begin
//  CcConfigStorage.First;
//  CcConfigStorage.Locate('ConfigName', qSelectAliasesCONFIG_NAME.Value, []);
//  aField := CcConfigStorage.FieldByName('CONFIGID');
//  if (not aField.IsNull) then
//		Value := aField.AsInteger
//	else
//		Value := -1;
//	Result := Value;
//end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.StartAutoReplication();
begin
	StartStopAutoReplication(true);
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.StartStopAutoReplication(const IsStartRequest: boolean);
var
	aReplicator: TCcReplicator;
	ConfigID: integer;
begin
	CcConfigStorage.First();
	while (not CcConfigStorage.Eof) do begin
		ConfigID := CcConfigStorage.ConfigID;
		aReplicator := CcReplicatorList.Replicators[ConfigID];
		if (Assigned(aReplicator)) then
		begin
			if (IsStartRequest) then
				aReplicator.AutoReplicate.Start()
			else
				aReplicator.AbortReplication();
		end;
		ccConfigStorage.Next();
	end;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.StopAutoReplication();
begin
	StartStopAutoReplication(false);
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.DoReplicate();
var
	aReplicator: TCcReplicator;
begin
	aReplicator := CcReplicatorList.CurrentReplicator;
	if (Assigned(aReplicator)) then
		aReplicator.Replicate();
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.CcReplicatorListReplicationError(Sender: TObject; e: Exception; var CanContinue: Boolean);
var
	aLog: TCcCustomLog;
	aReplicator: TCcReplicator;
	LogID: integer;
	PrimaryKeys: string;
	TableName: string;
  cConfigName: String;
begin
	// row was not replicated
	aReplicator := Sender as TCcReplicator;
  cConfigName := AReplicator.ConfigurationName;
	LogID := GetLogID(cConfigName);
	if (LogID <> -1) then begin
		aLog := aReplicator.Log;
		TableName := aLog.FBN('TABLE_NAME');
		PrimaryKeys := aLog.FBN('PRIMARY_KEY_VALUES');
		UpdateLog(cConfigName, LogID, raIncError, false);
		InsertLogError(cConfigName, LogID, TableName, PrimaryKeys, e.Message);
	end;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.CcReplicatorListRowReplicated(Sender: TObject);
var
	aReplicator: TCcReplicator;
	LogID: integer;
  cConfigName: String;
begin
	// row was replicated
	aReplicator := Sender as TCcReplicator;
  cConfigName := AReplicator.ConfigurationName;
	LogID := GetLogID(cConfigName);
	if (LogID <> -1) then
		UpdateLog(cConfigName, LogID, raIncOK, false);
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.CcReplicatorListException(Sender: TObject; e: Exception);
var
	aLog: TCcCustomLog;
	aReplicator: TCcReplicator;
	LogID: integer;
	PrimaryKeys: string;
	TableName: string;
  cConfigName: String;
begin
	// an unexpected error occured, job aborted !
	aReplicator := Sender as TCcReplicator;
  cConfigName := AReplicator.ConfigurationName;
	LogID := GetLogID(cConfigName);
	if (LogID = -1) then begin		// if LogID = -1 then most probable explanation is that the exception occurred before the OnLogLoaded event, so try to add a new log
		AddLog(cConfigName);
		LogID := GetLogID(cConfigName);
	end;
	if (LogID <> -1) then begin
		aLog := aReplicator.Log;
		TableName := aLog.FBN('TABLE_NAME');
		PrimaryKeys := aLog.FBN('PRIMARY_KEY_VALUES');
		InsertLogError(cConfigName, LogID, TableName, PrimaryKeys, e.Message);
		UpdateLog(cConfigName, LogID, raIncError, true);
		if (Assigned(FOnEndSync)) then
			FOnEndSync(Sender);
	end;
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.CcReplicatorListEmptyLog(Sender: TObject);
var
	aReplicator: TCcReplicator;
	cConfigName: string;
	LogID: integer;
begin
	aReplicator := Sender as TCcReplicator;
	if (Assigned(AReplicator)) then begin
    cConfigName := AReplicator.ConfigurationName;
		AddLog(cConfigName);
		LogID := GetLogID(cConfigName);
		if (LogID <> -1) then
			UpdateLog(cConfigName, LogID, raNone, true);
		if (Assigned(FOnEndSync)) then
			FOnEndSync(Sender);
	end;
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.CcReplicatorListFinished(Sender: TObject);
var
	aReplicator: TCcReplicator;
	LogID: integer;
	cConfigName: string;
begin
	aReplicator := Sender as TCcReplicator;
	if (Assigned(aReplicator)) then begin
    cConfigName := AReplicator.ConfigurationName;
		LogID := GetLogID(cConfigName);
		UpdateLog(cConfigName, LogID, raNone, true);
		if (Assigned(FOnEndSync)) then
			FOnEndSync(Sender);
	end;
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.AddLog(const Alias: string);
var
	ConfigID: integer;
	Index: integer;
	LogID: integer;
	Value: string;
begin
	Value := AnsiReplaceStr(Alias, ' ', 'ù');
	LogID := InsertLog(Alias);
	Index := FLogLinks.IndexOfName(Value);
	if (Index <> -1) then
		FLogLinks.Delete(Index);
	FLogLinks.Add(Format('%s=%d', [Value, LogID]));
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.InsertLogError(cConfigName: String; const LogID: integer; const TableName: string; const PrimaryKeys: string; const ErrorMessage: string);
var
	aStream: TMemoryStream;
begin
	try
		qInsertLogError.Close;
		qInsertLogError.ParamByName('LOG_ID').AsInteger := LogID;
		qInsertLogError.ParamByName('TABLE_NAME').AsString := TableName;
		qInsertLogError.ParamByName('PRIMARY_KEYS').AsString := PrimaryKeys;
//		aStream := TMemoryStream.Create();
//		aStream.Position := 0;
//		aStream.WriteBuffer(PChar(ErrorMessage)^, Length(ErrorMessage));
		qInsertLogError.ParamByName('ERROR_MESSAGE').Value := ErrorMessage; //LoadFromStream(aStream);
//		FreeAndNil(aStream);
		qInsertLogError.ExecQuery();
		trLog.CommitRetaining();

    if Assigned(FOnRefreshLogError) then
      FOnRefreshLogError(cConfigName, LogID);
	except
		on E: Exception do begin
			trLog.RollbackRetaining();
			raise E;
		end;
	end;
end;
//----------------------------------------------------------------------------
function TdmLogsAndSettings.GetLogID(const Alias: string): integer;
var
	Index: integer;
	Value: integer;
begin
	Index := FLogLinks.IndexOfName(AnsiReplaceStr(Alias, ' ', 'ù'));
	if (Index = -1) then
		Value := -1
	else
    Result := StrToIntDef(FLogLinks.ValueFromIndex[Index], -1);
end;
//----------------------------------------------------------------------------
function TdmLogsAndSettings.GetLogID(AReplicator: TccReplicator): integer;
var
	Value: integer;
	Alias: string;
begin
	if (Assigned(AReplicator)) then begin
		Alias := aReplicator.Log.Dest.Name;
		Value := GetLogID(Alias);
	end
	else begin
		Value := -1;
	end;
	Result := Value;
end;
//----------------------------------------------------------------------------
procedure TdmLogsAndSettings.DoConvertMessage(Sender: TField; var Text: String; DisplayText: Boolean);
var
	aStream: TMemoryStream;
	aStrings: TStringList;
begin
	aStream := TMemoryStream.Create();
	aStrings := TStringList.Create();
	(Sender.DataSet.FieldByName('ERROR_MESSAGE') as TBlobField).SaveToStream(aStream);
	aStream.Seek(0, soFromBeginning);
	aStrings.LoadFromStream(aStream);
	Text := aStrings.Text;
	FreeAndNil(aStream);
	FreeAndNil(aStrings);
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.DoConvertDateTimeAsLocalSettings(Sender: TField; var Text: String; DisplayText: Boolean);
var
	aDateField: TField;
begin
	aDateField := Sender.DataSet.FieldByName('DATE_SYNC');
	if (not aDateField.IsNull) then
		Text := DateTimeToStr(aDateField.AsDateTime, FFormatSettings);
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.RemoveTriggers(AConnection: TCcConnection);
var
	TableName: string;
begin
	try
	  AConnection.Connect;
		qRPLTables.Close();
		qRPLTables.Connection := AConnection;
		qRPLTables.Prepare();
		qRPLTables.Exec();
		while (not qRPLTables.Eof) do begin
			TableName := Trim(qRPLTables.FieldByIndex[0].AsString);
			if (AnsiContainsStr(TableName, 'RPL$')) then
				CcConfig.RemoveTriggers(TableName);
			qRPLTables.Next();
		end;
	finally
		qRPLTables.Connection.CommitRetaining();
	end;
end;
//-----------------------------------------------------------------------------
function TdmLogsAndSettings.GetOnRefreshLog(): TRefreshLogEvent;
begin
	Result := FOnRefreshLog;
end;
//-----------------------------------------------------------------------------
function TdmLogsAndSettings.GetOnRefreshLogError(): TRefreshLogErrorEvent;
begin
	Result := FOnRefreshLogError;
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.SetOnRefreshLog(const Value: TRefreshLogEvent);
begin
	FOnRefreshLog := Value;
end;
//-----------------------------------------------------------------------------
procedure TdmLogsAndSettings.SetOnRefreshLogError(const Value: TRefreshLogErrorEvent);
begin
	FOnRefreshLogError := Value;
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.StopCurrentAutoReplication;
var
  aReplicator: TCcReplicator;
begin
	aReplicator := CcReplicatorList.CurrentReplicator;
	if (Assigned(aReplicator)) then
		aReplicator.AutoReplicate.Stop();
end;

procedure TdmLogsAndSettings.StartCurrentAutoReplication;
var
  aReplicator: TCcReplicator;
begin
	aReplicator := CcReplicatorList.CurrentReplicator;
	if (Assigned(aReplicator)) then
		aReplicator.AutoReplicate.Start;
end;

end.
