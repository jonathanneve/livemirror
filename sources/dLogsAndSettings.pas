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
		ibdLog: TpFIBDatabase;
		ibtSelectAliases: TpFIBTransaction;
		ibqSelectAliases: TpFIBQuery;
		dtsSelectAliasesDS: TDataSource;
		dtsSelectAliases: TpFIBDataSet;
		ccqSelectRplTables: TCcQuery;
		ibsInsertAlias: TpFIBStoredProc;
		ibtInsertAlias: TpFIBTransaction;
		ccqInsertUser: TCcQuery;
		ccqSelectUser: TCcQuery;
		ibtSelectAliasByName: TpFIBTransaction;
		ibqSelectAliasByName: TpFIBQuery;
		ibtInsertLog: TpFIBTransaction;
		ibsInsertLog: TpFIBStoredProc;
		ibtDeleteAlias: TpFIBTransaction;
		ibsDeleteAlias: TpFIBStoredProc;
		ibtInsertLogError: TpFIBTransaction;
		ibtUpdateLog: TpFIBTransaction;
		ibsUpdateLog: TpFIBStoredProc;
		dtsSelectAliasesALIAS_ID: TFIBIntegerField;
		dtsSelectAliasesCONFIG_ID: TFIBIntegerField;
		dtsSelectAliasesCONFIG_NAME: TFIBStringField;
		dtsSelectAliasesDATE_SYNC: TFIBDateTimeField;
		dtsSelectAliasesRECORDS_ERROR: TFIBIntegerField;
		dtsSelectAliasesTRANSFER_STATUS: TFIBSmallIntField;
		dtsSelectAliasesCONVERTED_STATUS: TStringField;
		ibtSelectLog: TpFIBTransaction;
		dtsSelectLog: TpFIBDataSet;
		dtsSelectLogDS: TDataSource;
		dtsSelectLogLOG_ID: TFIBIntegerField;
		dtsSelectLogCONFIG_ID: TFIBIntegerField;
		dtsSelectLogCONFIG_NAME: TFIBStringField;
		dtsSelectLogDATE_SYNC: TFIBDateTimeField;
		dtsSelectLogRECORDS_OK: TFIBIntegerField;
		dtsSelectLogRECORDS_ERROR: TFIBIntegerField;
		dtsSelectLogTRANSFER_STATUS: TFIBSmallIntField;
		dtsSelectLogCONVERTED_STATUS: TStringField;
		ibsInsertLogError: TpFIBStoredProc;
		ibtSelectLogErrors: TpFIBTransaction;
		dtsSelectLogErrors: TpFIBDataSet;
		dtsSelectLogErrorsDS: TDataSource;
		dtsSelectLogErrorsLOG_ERROR_ID: TFIBIntegerField;
		dtsSelectLogErrorsLOG_ID: TFIBIntegerField;
		dtsSelectLogErrorsTABLE_NAME: TFIBStringField;
		dtsSelectLogErrorsPRIMARY_KEYS: TFIBStringField;
		dtsSelectLogErrorsERROR_MESSAGE: TFIBMemoField;
		dtsSelectLogErrorsCONVERTED_MESSAGE: TStringField;
		procedure DataModuleCreate(Sender: TObject);
		procedure DataModuleDestroy(Sender: TObject);
		procedure CcReplicatorListException(Sender: TObject; e: Exception);
		procedure CcReplicatorListLogLoaded(Sender: TObject);
		procedure CcReplicatorListReplicationError(Sender: TObject; e: Exception; var CanContinue: Boolean);
		procedure CcReplicatorListRowReplicated(Sender: TObject);
		procedure CcReplicatorListEmptyLog(Sender: TObject);
		procedure CcReplicatorListFinished(Sender: TObject);
		procedure DoConvertStatus(Sender: TField; var Text: String; DisplayText: Boolean);
		procedure dtsSelectLogDSDataChange(Sender: TObject; Field: TField);
		procedure DoConvertMessage(Sender: TField; var Text: String; DisplayText: Boolean);
		procedure DoConvertDateTimeAsLocalSettings(Sender: TField; var Text: String; DisplayText: Boolean);
	private
		{ Private declarations }
		FFormatSettings: TFormatSettings;
		FLogLinks: THashedStringList;
		FOnEndSync: TNotifyEvent;
		FOnRefreshLog: TRefreshLogEvent;
		FOnRefreshLogError: TRefreshLogEvent;

		procedure AddLog(const Alias: string);
		procedure AddUser(const Value: string);
		procedure Append();
		procedure DeleteAlias(var ErrorMessage: string);
		function DoDeleteSettings(const IsRemoveTriggers: boolean): string;
		procedure DoCancelSettings();
		function DoRefreshSettings(): string;
		procedure DoReplicate();
		function DoSaveSettings(): string;
		procedure DoViewLog();
		procedure EditSettings(const Value: integer);
		procedure GenerateMissingTriggers(AConnection: TCcConnection);
		function GetIsAliasExist(const Name: string): integer;
		function GetIsUserExist(const UserName: string): boolean;
		function GetLocalDB(): TCcConnectionConfig;
		function GetLogID(const Alias: string): integer; overload;
		function GetLogID(AReplicator: TccReplicator): integer; overload;
		function GetOnEndSync(): TNotifyEvent;
		function GetOnRefreshLog(): TRefreshLogEvent;
		function GetOnRefreshLogError(): TRefreshLogEvent;
		function GetRemoteDB(): TCcConnectionConfig;
		function GetSelectedConfigID(): integer;
		function GetStoredConfigID(): integer;
		function IsCanSaveSettings(var ErrorMessage: string): boolean;
		procedure InsertAlias();
		function InsertLog(const ConfigID: integer): integer;
		procedure InsertLogError(const LogID: integer; const TableName: string; const PrimaryKeys: string; const ErrorMessage: string);
		procedure RemoveTriggers(AConnection: TCcConnection);
		procedure SaveSettings(var ErrorMessage: string);
		procedure SetOnEndSync(const Value: TNotifyEvent);
		procedure SetOnRefreshLog(const Value: TRefreshLogEvent);
		procedure SetOnRefreshLogError(const Value: TRefreshLogEvent);
		procedure StartAutoReplication();
		procedure StartStopAutoReplication(const IsStartRequest: boolean);
		procedure StopAutoReplication();
		function UpdateLog(const LogID: integer; const ReplicationAction: TReplicationAction; const IsTransferTerminated: boolean): integer;
	public
		{ Public declarations }
	end;

var
	dmLogsAndSettings: TdmLogsAndSettings;

implementation

uses
	Forms,
	FIB,
	Windows,
	StrUtils;

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
	ibdLog.DBName := 'localhost:LiveMirror';
	ibdLog.Open();
	dtsSelectAliases.Open();
	StartAutoReplication();
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.DataModuleDestroy(Sender: TObject);
begin
	StopAutoReplication();
	CcConfig.Disconnect();
	ibdLog.Close();
	FreeAndNil(FLogLinks);
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.GenerateMissingTriggers(AConnection: TCcConnection);
var
	TableName: string;
begin
	try
		ccqSelectRplTables.Close();
		ccqSelectRplTables.Connection := AConnection;
		ccqSelectRplTables.Prepare();
		ccqSelectRplTables.Exec();
		while (not ccqSelectRplTables.Eof) do begin
			TableName := Trim(ccqSelectRplTables.FieldByIndex[0].AsString);
			if (not AnsiContainsStr(TableName, 'RPL$')) then
				CcConfig.GenerateTriggers(TableName);
			ccqSelectRplTables.Next();
		end;
	finally
		ccqSelectRplTables.Connection.CommitRetaining();
	end;
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.AddUser(const Value: string);
begin
	if (not GetIsUserExist(Value)) then begin
		try
			ccqInsertUser.Close();
			ccqInsertUser.Connection := CcConfigStorage.LocalDB.Connection;
			ccqInsertUser.Prepare();
			ccqInsertUser.Param['ALIAS_NAME'].AsString := UpperCase(Value);
			ccqInsertUser.Exec();
		finally
			ccqInsertUser.Connection.CommitRetaining();
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

function TdmLogsAndSettings.DoSaveSettings(): string;
var
	ErrorMessage: string;
	IsCanSave: boolean;
begin
	IsCanSave := IsCanSaveSettings(ErrorMessage);
	if ( (IsCanSave) or (CcConfigStorage.State = dsEdit) ) then
		SaveSettings(ErrorMessage);
	if (ErrorMessage <> '') then
		ErrorMessage := Format('Can''t save settings !%s%s', [#13#10#13#10, ErrorMessage]);
	Result := ErrorMessage;
end;
//-----------------------------------------------------------------------------

function TdmLogsAndSettings.IsCanSaveSettings(var ErrorMessage: string): boolean;
var
	ConfigName: string;
	Value: boolean;
begin
	ConfigName := CcConfigStorage.FieldByName('ConfigName').AsString;
	if (ConfigName = '') then begin
		ErrorMessage := 'Alias is empty !';
	end
	else begin
		if (GetIsAliasExist(ConfigName) <> 0) then
			ErrorMessage := Format('Alias ''%s'' already exist', [ConfigName]);
	end;
	Value := ErrorMessage = '';
	Result := Value;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.SaveSettings(var ErrorMessage: string);
var
	RemoteNodeName: string;
begin
	try
		RemoteNodeName := UpperCase(CcConfigStorage.FieldByName('ConfigName').AsString);
		CcConfig.Connection := CcConfigStorage.LocalDB.Connection;
		CcConfig.Connect();
		CcConfigStorage.FieldByName('LocalNodeName').AsString := 'MASTER';
		CcConfigStorage.FieldByName('RemoteNodeName').AsString := RemoteNodeName;
		CcConfigStorage.FieldByName('ReplicationMode').AsString := 'BIDI';
		GenerateMissingTriggers(CcConfig.Connection);
		AddUser(RemoteNodeName);
		// connection to mirror database
		CcConfig.Connection := CcConfigStorage.RemoteDB.Connection;
		CcConfig.Connect();

		CcConfigStorage.Post();

		InsertAlias();

		CcReplicatorList.CurrentReplicator.AutoReplicate.Start();
		ErrorMessage := '';
		if (Assigned(FOnEndSync)) then
			FOnEndSync(Self);
	except
		on E: Exception do begin
			ErrorMessage := E.Message;
			CcConfigStorage.Cancel();
		end;
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
	CcConfigStorage.Cancel();
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.InsertAlias();
var
	AliasName: string;
begin
	AliasName := UpperCase(CcConfigStorage.FieldValues['ConfigName']);
	if (GetIsAliasExist(AliasName) = 0) then begin
		try
			ibtInsertAlias.StartTransaction();
			ibsInsertAlias.ParamByName('CONFIG_ID').AsInteger := CcConfigStorage.ConfigID;
			ibsInsertAlias.ParamByName('CONFIG_NAME').AsString := AliasName;
			ibsInsertAlias.ExecProc();
			ibtInsertAlias.Commit();
		except
			on E: Exception do begin
				ibtInsertAlias.Rollback();
				raise E;
			end;
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

function TdmLogsAndSettings.GetIsAliasExist(const Name: string): integer;
// return value : ConfigID
var
	aField: TFIBXSQLVAR;
	Value: integer;
begin
	try
		ibtSelectAliasByName.StartTransaction();
		ibqSelectAliasByName.ParamByName('NAME').AsString := UpperCase(Name);
		ibqSelectAliasByName.ExecQuery();
		aField := ibqSelectAliasByName.FieldByName('CONFIG_ID');
		if (aField.IsNull) then
			Value := 0
		else
			Value := aField.AsInteger;
	finally
		ibtSelectAliasByName.Commit();
	end;
	Result := Value;
end;
//-----------------------------------------------------------------------------

function TdmLogsAndSettings.GetIsUserExist(const UserName: string): boolean;
var
	Value: boolean;
begin
	try
		Value := false;
		ccqSelectUser.Close();
		ccqSelectUser.Connection := CcConfigStorage.LocalDB.Connection;
		ccqSelectUser.Prepare();
		ccqSelectUser.Param['USER_NAME'].AsString := UpperCase(UserName);
		ccqSelectUser.Exec();
		Value := not ccqSelectUser.Eof;
	finally
		ccqSelectUser.Connection.CommitRetaining();
	end;
	Result := Value;
end;
//----------------------------------------------------------------------------

function TdmLogsAndSettings.DoRefreshSettings(): string;
var
	ErrorMessage: string;
begin
	CcConfigStorage.ConfigID := dtsSelectAliases.FieldValues['CONFIG_ID'];		// selected ConfigID
	CcConfigStorage.Edit();
	SaveSettings(ErrorMessage);
	if (ErrorMessage <> '') then
		ErrorMessage := Format('Can''t refresh settings !%s%s', [#13#10#13#10, ErrorMessage]); 
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

function TdmLogsAndSettings.InsertLog(const ConfigID: integer): integer;
var
	aField: TFIBXSQLVAR;
	Value: integer;
begin
	try
		ibtInsertLog.StartTransaction();
		ibsInsertLog.ParamByName('CONFIG_ID').AsInteger := ConfigID;
		ibsInsertLog.ExecProc();
		aField := ibsInsertLog.FldByName['LOG_ID'];
		if (aField.IsNull) then
			Value := -1
		else
			Value := aField.AsInteger;
		ibtInsertLog.Commit();
	except
		on E: Exception do begin
			ibtInsertLog.Rollback();
			raise E;
		end;
	end;
	Result := Value;
end;
//----------------------------------------------------------------------------

function TdmLogsAndSettings.UpdateLog(const LogID: integer; const ReplicationAction: TReplicationAction; const IsTransferTerminated: boolean): integer;
var
	aField: TFIBXSQLVAR;
	Value: integer;
begin
	try
		ibtUpdateLog.StartTransaction();
		ibsUpdateLog.ParamByName('LOG_ID').AsInteger := LogID;
		ibsUpdateLog.ParamByName('INC_RECORDS_OK').AsShort := ord(ReplicationAction = raIncOK);
		ibsUpdateLog.ParamByName('INC_RECORDS_ERROR').AsShort := ord(ReplicationAction = raIncError);
		ibsUpdateLog.ParamByName('TRANSFER_STATUS').AsShort := ord(IsTransferTerminated);

		ibsUpdateLog.ExecProc();
		aField := ibsUpdateLog.FldByName['ID'];
		if (aField.IsNull) then
			Value := -1
		else
			Value := aField.AsInteger;
		ibtUpdateLog.Commit();

		DoViewLog();
	except
		on E: Exception do begin
			ibtUpdateLog.Rollback();
			raise E;
		end;
	end;
	Result := Value;
end;
//----------------------------------------------------------------------------

function TdmLogsAndSettings.DoDeleteSettings(const IsRemoveTriggers: boolean): string;
var
	ErrorMessage: string;
	ConfigID: integer;
	aReplicator: TCcReplicator;
begin
	ConfigID := CcConfigStorage.ConfigID;
	aReplicator := CcReplicatorList.Replicators[ConfigID];
	if (Assigned(aReplicator)) then
	begin
		aReplicator.AutoReplicate.Stop();
		if (IsRemoveTriggers) then begin
			RemoveTriggers(CcConfigStorage.LocalDB.Connection);
			RemoveTriggers(CcConfigStorage.RemoteDB.Connection);
		end;
		DeleteAlias(ErrorMessage);
		if (ErrorMessage <> '') then
			ErrorMessage := Format('Can''t delete settings !%s%s', [#13#10#13#10, ErrorMessage]);

		CcConfigStorage.Delete;

		if (Assigned(FOnEndSync)) then
			FOnEndSync(Self);
	end;
	Result := ErrorMessage;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.DeleteAlias(var ErrorMessage: string);
var
	AliasID: integer;
begin
	try
		AliasID := dtsSelectAliases.FieldValues['ALIAS_ID'];
		ibtDeleteAlias.StartTransaction();
		ibsDeleteAlias.ParamByName('ALIAS_ID').AsInteger := AliasID;
		ibsDeleteAlias.ExecProc();
		ibtDeleteAlias.Commit();
	except
		on E: Exception do begin
			ibtDeleteAlias.Rollback();
			ErrorMessage := E.Message;
		end;
	end;
end;
//----------------------------------------------------------------------------

function TdmLogsAndSettings.GetSelectedConfigID(): integer;
var
	aField: TField;
	Value: integer;
begin
	aField := dtsSelectAliases.FieldByName('CONFIG_ID');
	if (not aField.IsNull) then
		Value := aField.AsInteger
	else
		Value := -1;
	Result := Value;
end;
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
	aReplicator := CcReplicatorList.Replicators[GetSelectedConfigID];
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
begin
	// row was not replicated
	aReplicator := Sender as TCcReplicator;
	LogID := GetLogID(aReplicator);
	if (LogID <> -1) then begin
		aLog := aReplicator.Log;
		TableName := aLog.FBN('TABLE_NAME');
		PrimaryKeys := aLog.FBN('PRIMARY_KEY_VALUES');
		UpdateLog(LogID, raIncError, false);
		InsertLogError(LogID, TableName, PrimaryKeys, e.Message);
	end;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.CcReplicatorListRowReplicated(Sender: TObject);
var
	aReplicator: TCcReplicator;
	LogID: integer;
begin
	// row was replicated
	aReplicator := Sender as TCcReplicator;
	LogID := GetLogID(aReplicator);
	if (LogID <> -1) then
		UpdateLog(LogID, raIncOK, false);
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.CcReplicatorListException(Sender: TObject; e: Exception);
var
	Alias: string;
	aLog: TCcCustomLog;
	aReplicator: TCcReplicator;
	LogID: integer;
	PrimaryKeys: string;
	TableName: string;
begin
	// an unexpected error occured, job aborted !
	aReplicator := Sender as TCcReplicator;
	LogID := GetLogID(aReplicator);
	if (LogID = -1) then begin		// if LogID = -1 then most probable explanation is that the exception occurred before the OnLogLoaded event, so try to add an new log
		Alias := aReplicator.Log.Origin.Name;
		AddLog(Alias);
		LogID := GetLogID(Alias);
	end;
	if (LogID <> -1) then begin
		aLog := aReplicator.Log;
		TableName := aLog.FBN('TABLE_NAME');
		PrimaryKeys := aLog.FBN('PRIMARY_KEY_VALUES');
		InsertLogError(LogID, TableName, PrimaryKeys, e.Message);
		UpdateLog(LogID, raIncError, true);
		if (Assigned(FOnEndSync)) then
			FOnEndSync(Sender);
	end;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.CcReplicatorListEmptyLog(Sender: TObject);
var
	aReplicator: TCcReplicator;
	Alias: string;
	LogID: integer;
begin
	aReplicator := Sender as TCcReplicator;
	if (Assigned(AReplicator)) then begin
		Alias := aReplicator.Log.Origin.Name;
		AddLog(Alias);
		LogID := GetLogID(Alias);
		if (LogID <> -1) then
			UpdateLog(LogID, raNone, true);
		if (Assigned(FOnEndSync)) then
			FOnEndSync(Sender);
	end;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.CcReplicatorListFinished(Sender: TObject);
var
	aReplicator: TCcReplicator;
	LogID: integer;
	Alias: string;
begin
	aReplicator := Sender as TCcReplicator;
	if (Assigned(aReplicator)) then begin
		Alias := aReplicator.Log.Dest.Name;
		LogID := GetLogID(Alias);
		UpdateLog(LogID, raNone, true);
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
	ConfigID := GetIsAliasExist(Alias);
	LogID := InsertLog(ConfigID);
	Index := FLogLinks.IndexOfName(Value);
	if (Index <> -1) then
		FLogLinks.Delete(Index);
	FLogLinks.Add(Format('%s=%d', [Value, LogID]));
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.InsertLogError(const LogID: integer; const TableName: string; const PrimaryKeys: string; const ErrorMessage: string);
var
	aStream: TMemoryStream;
begin
	try
		ibtInsertLogError.StartTransaction();
		ibsInsertLogError.ParamByName('LOG_ID').AsInteger := LogID;
		ibsInsertLogError.ParamByName('TABLE_NAME').AsString := TableName;
		ibsInsertLogError.ParamByName('PRIMARY_KEYS').AsString := PrimaryKeys;
		aStream := TMemoryStream.Create();
		aStream.Position := 0;
		aStream.WriteBuffer(PChar(ErrorMessage)^, Length(ErrorMessage));
		ibsInsertLogError.ParamByName('ERROR_MESSAGE').LoadFromStream(aStream);
		FreeAndNil(aStream);
		ibsInsertLogError.ExecProc();
		ibtInsertLogError.Commit();

		DoViewLog();
	except
		on E: Exception do begin
			ibtInsertLogError.Rollback();
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
	if (Index = -1) then begin
		Value := -1;
	end
	else begin
		if (not TryStrToInt(FLogLinks.ValueFromIndex[Index], Value)) then
			Value := -1;
	end;
	Result := Value;
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

procedure TdmLogsAndSettings.DoConvertStatus(Sender: TField; var Text: String; DisplayText: Boolean);
var
	aDataSet: TDataSet;
	aStatusField: TField;
	aDateField: TField;
	ErrorsCount: integer;
	IsTerminated: boolean;
	StatusMessage: string;
begin
	aDataSet := Sender.DataSet;
	ErrorsCount := aDataSet.FieldByName('RECORDS_ERROR').AsInteger;
	aDateField := aDataSet.FieldByName('DATE_SYNC');
	aStatusField := aDataSet.FieldByName('TRANSFER_STATUS');
	if (aDateField.IsNull) then begin
		Text := '';
	end
	else begin
		IsTerminated := boolean(aStatusField.AsInteger);
		if (ErrorsCount > 0) then
			StatusMessage := ' with errors !';

		if (not IsTerminated) then 
			Text := 'Running...'
		else
			Text := Format ('Terminated%s', [StatusMessage]);
	end;
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.DoViewLog();
begin
	dtsSelectLog.Close();
	ibtSelectLog.StartTransaction();
	dtsSelectLog.ParamByName('ID').AsInteger := GetSelectedConfigID;
	dtsSelectLog.Open();
	ibtSelectLog.CommitRetaining();
end;
//----------------------------------------------------------------------------

procedure TdmLogsAndSettings.dtsSelectLogDSDataChange(Sender: TObject; Field: TField);
var
	LogID: integer;
begin
	LogID := TDataSource(Sender).DataSet.FieldByName('LOG_ID').AsInteger;
	dtsSelectLogErrors.Close();
	ibtSelectLogErrors.StartTransaction();
	dtsSelectLogErrors.ParamByName('ID').AsInteger := LogID;
	dtsSelectLogErrors.Open();
	ibtSelectLogErrors.CommitRetaining();
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
		ccqSelectRplTables.Close();
		ccqSelectRplTables.Connection := AConnection;
		ccqSelectRplTables.Prepare();
		ccqSelectRplTables.Exec();
		while (not ccqSelectRplTables.Eof) do begin
			TableName := Trim(ccqSelectRplTables.FieldByIndex[0].AsString);
			if (AnsiContainsStr(TableName, 'RPL$')) then
				CcConfig.RemoveTriggers(TableName);
			ccqSelectRplTables.Next();
		end;
	finally
		ccqSelectRplTables.Connection.CommitRetaining();
	end;
end;
//-----------------------------------------------------------------------------

function TdmLogsAndSettings.GetOnRefreshLog(): TRefreshLogEvent;
begin
	Result := FOnRefreshLog;
end;
//-----------------------------------------------------------------------------

function TdmLogsAndSettings.GetOnRefreshLogError(): TRefreshLogEvent;
begin
	Result := FOnRefreshLogError;
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.SetOnRefreshLog(const Value: TRefreshLogEvent);
begin
	FOnRefreshLog := Value;
end;
//-----------------------------------------------------------------------------

procedure TdmLogsAndSettings.SetOnRefreshLogError(const Value: TRefreshLogEvent);
begin
	FOnRefreshLogError := Value;
end;
//-----------------------------------------------------------------------------

end.
