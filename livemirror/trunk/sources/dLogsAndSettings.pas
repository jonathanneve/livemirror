unit dLogsAndSettings;

interface

uses
	SysUtils, Classes, CcConf, CcDB, DB, CcMemDS, CcConfStorage, CcRplList,
	RzCommon, CcConnADO, CcProviders, CcProvFIBPlus;

type
	TdmLogsAndSettings = class(TDataModule)
		CcReplicatorList1: TCcReplicatorList;
		CcConfigStorage: TCcConfigStorage;
		CcDataSet1: TCcDataSet;
		CcConfig: TCcConfig;
		CcConfigStorageDS: TDataSource;
		FrameController: TRzFrameController;
    CcConnectionFIB1: TCcConnectionFIB;
    CcConnectionADO1: TCcConnectionADO;
	private
		{ Private declarations }
		FOnEndSync: TNotifyEvent;

		function GetOnEndSync(): TNotifyEvent;
		procedure SetOnEndSync(const Value: TNotifyEvent);
	public
		{ Public declarations }
		property OnEndSync: TNotifyEvent read GetOnEndSync write SetOnEndSync;
	end;

var
	dmLogsAndSettings: TdmLogsAndSettings;

implementation

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

end.
