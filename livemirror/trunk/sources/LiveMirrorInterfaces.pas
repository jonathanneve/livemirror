unit LiveMirrorInterfaces;

interface

uses
	Classes,
	CcConfStorage;

type
	TTransferStatus = (tsNone, tsRunning, tsAborted, tsFinishedWithErrors, tsFinished);
	TRefreshLogEvent = procedure(const ConfigID: integer) of object; 

	ISettingsModel = interface
	['{8D70CD04-2D02-48FD-99ED-B2E151C1182E}']
		procedure Append();
		function DoDeleteSettings(const IsRemoveTriggers: boolean): string;
		procedure DoCancelSettings();
		function DoRefreshSettings(): string;
		procedure DoReplicate();
		function DoSaveSettings(): string;
		procedure DoViewLog();
		procedure EditSettings(const Value: integer);
		function GetLocalDB(): TCcConnectionConfig;
		function GetOnEndSync(): TNotifyEvent;
		function GetOnRefreshLog(): TRefreshLogEvent;
		function GetOnRefreshLogError(): TRefreshLogEvent;
		function GetRemoteDB(): TCcConnectionConfig;
		function GetSelectedConfigID(): integer;
		function GetStoredConfigID(): integer;
		procedure SetOnEndSync(const Value: TNotifyEvent);
		procedure SetOnRefreshLog(const Value: TRefreshLogEvent);
		procedure SetOnRefreshLogError(const Value: TRefreshLogEvent);
		procedure StartAutoReplication();
		procedure StopAutoReplication();

		property LocalDB: TCcConnectionConfig read GetLocalDB;
		property OnEndSync: TNotifyEvent read GetOnEndSync write SetOnEndSync;
		property OnRefreshLog: TRefreshLogEvent read GetOnRefreshLog write SetOnRefreshLog;
		property OnRefreshLogError: TRefreshLogEvent read GetOnRefreshLogError write SetOnRefreshLogError;
		property RemoteDB: TCcConnectionConfig read GetRemoteDB;
		property SelectedConfigID: integer read GetSelectedConfigID;
		property StoredConfigID: integer read GetStoredConfigID;
	end;

	ISettingsView = interface
	['{ABEEB2B0-A4A7-49CE-B222-5A267321B509}']
	end;

implementation

end.
