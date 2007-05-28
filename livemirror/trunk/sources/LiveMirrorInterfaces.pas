unit LiveMirrorInterfaces;

interface

uses
	Classes,
	CcConfStorage;

type
	TTransferStatus = (tsNone, tsRunning, tsAborted, tsFinishedWithErrors, tsFinished);
	TRefreshLogEvent = procedure(AConfigName: String) of object;
	TRefreshLogErrorEvent = procedure(AConfigName: String; LogID: Integer) of object;

	ISettingsModel = interface
	['{8D70CD04-2D02-48FD-99ED-B2E151C1182E}']
		procedure Append();
		function DoDeleteSettings(const IsRemoveTriggers: boolean): string;
		procedure DoCancelSettings();
		function DoRefreshSettings(): string;
		function DoReplicate(): Boolean;
		function DoSaveSettings(lNew: Boolean): Boolean;
		procedure EditSettings(const Value: integer);
		function GetLocalDB(): TCcConnectionConfig;
		function GetOnEndSync(): TNotifyEvent;
		function GetOnRefreshLog(): TRefreshLogEvent;
		function GetOnRefreshLogError(): TRefreshLogErrorEvent;
		function GetRemoteDB(): TCcConnectionConfig;
//		function GetSelectedConfigID(): integer;
		function GetStoredConfigID(): integer;
		procedure SetOnEndSync(const Value: TNotifyEvent);
		procedure SetOnRefreshLog(const Value: TRefreshLogEvent);
		procedure SetOnRefreshLogError(const Value: TRefreshLogErrorEvent);
		procedure StartAutoReplication();
		procedure StopAutoReplication();
		procedure StopCurrentAutoReplication();
		procedure StartCurrentAutoReplication();

		property LocalDB: TCcConnectionConfig read GetLocalDB;
		property OnEndSync: TNotifyEvent read GetOnEndSync write SetOnEndSync;
		property OnRefreshLog: TRefreshLogEvent read GetOnRefreshLog write SetOnRefreshLog;
		property OnRefreshLogError: TRefreshLogErrorEvent read GetOnRefreshLogError write SetOnRefreshLogError;
		property RemoteDB: TCcConnectionConfig read GetRemoteDB;
		property StoredConfigID: integer read GetStoredConfigID;
	end;

implementation

end.
