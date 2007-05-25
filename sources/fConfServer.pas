unit fConfServer;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, RzCmboBx, RzDBCmbo, Mask, RzEdit, RzDBEdit, ExtCtrls,
	RzPanel, Buttons, RzShellDialogs, CcConfStorage, DB, CcMemDS,
	fConfInterbase, fConfMSSQL, DBCtrls, CcProviders;

type
	TfrConfServer = class(TFrame)
		pnConnectParams: TRzPanel;
		mDBParams: TCcMemoryData;
		mDBParamsDBName: TStringField;
		mDBParamsUserLogin: TStringField;
		mDBParamsUserPassword: TStringField;
		mDBParamsCharset: TStringField;
		mDBParamsRoleName: TStringField;
		mDBParamsDBVersion: TStringField;
		mDBParamsDS: TDataSource;
    mDBParamsLibraryName: TStringField;
		mDBParamsSQLDialect: TIntegerField;
		mDBParamsConnectionString: TStringField;
		mDBParamsADOConnectionTimeout: TIntegerField;
		mDBParamsADOQueryTimeout: TIntegerField;
		frConfMSSQL: TfrConfMSSQL;
		frConfInterbase: TfrConfInterbase;
		mDBParamsDBType: TStringField;
		RzPanel1: TRzPanel;
		Label3: TLabel;
		Label1: TLabel;
    cbVersions: TRzDBComboBox;
		cbDatabaseType: TRzDBComboBox;
		procedure mDBParamsDBChange(Sender: TField);
		procedure cbVersionsChange(Sender: TObject);
    procedure mDBParamsDBTypeChange(Sender: TField);
    procedure cbDatabaseTypeChange(Sender: TObject);
	private
		ConnectionConfig: TCcConnectionConfig;
		FieldChanging, LoadingParams: Boolean;
    procedure RefreshVersions;
    procedure ReloadParams;
	protected
		procedure SetEnableControls(const Value: boolean); virtual;
	public
		ControlsEnabled: Boolean;
		procedure LoadParams(cnxConf: TCcConnectionConfig);
		{ Public declarations }
		constructor Create(AOwner: TComponent); override;
	end;

implementation

uses
	dLogsAndSettings;

{$R *.dfm}

procedure TfrConfServer.LoadParams(cnxConf: TCcConnectionConfig);
begin
	ConnectionConfig := cnxConf;
  ReloadParams;
end;

procedure TfrConfServer.ReloadParams;
var
	i : Integer;
	cFieldName: String;
begin
	LoadingParams := True;
	try
		mDBParams.Close;
		mDBParams.Open;
		mDBParams.Edit;
		for i:=0 to mDBParams.FieldCount-1 do begin
			cFieldName := mDBParams.Fields[i].FieldName;
			if ConnectionConfig.ParamExists(cFieldName) and (not VarIsNull(ConnectionConfig.Param[cFieldName])) then
				mDBParams.Fields[i].Value := ConnectionConfig.Param[cFieldName];
		end;
		mDBParams.Post;
	finally
		LoadingParams := False;
	end;
end;

procedure TfrConfServer.mDBParamsDBChange(Sender: TField);
begin
	if (not FieldChanging) and (not LoadingParams) then begin
		FieldChanging := True;
		try
			if ConnectionConfig.ParamExists(Sender.FieldName) then begin
				ConnectionConfig.Param[Sender.FieldName] := Sender.Value;
				Sender.Value := ConnectionConfig.Param[Sender.FieldName];
			end;
		finally
			FieldChanging := False;
		end;
	end;
end;

constructor TfrConfServer.Create(AOwner: TComponent);
var
	I: Integer;
begin
	inherited Create(AOwner);

	SetEnableControls(false);
	cbDatabaseType.Items.Clear;
	for I:=0 to CcAvailableAdaptors.Count-1 do
		cbDatabaseType.Items.Add(TCcDBAdaptorClass(CcAvailableAdaptors[i]).GetAdaptorName);
end;

procedure TfrConfServer.SetEnableControls(const Value: boolean);
begin
	pnConnectParams.Enabled := Value;
	frConfMSSQL.pnMSSQL.Enabled := Value;
	frConfInterbase.pnInterbase.Enabled := Value;
	ControlsEnabled := Value;
end;

procedure TfrConfServer.RefreshVersions;
var
	cConnectorType: string;
begin
	frConfMSSQL.Visible := (cbDatabaseType.Text = 'MSSQL');
	frConfInterbase.Visible := (cbDatabaseType.Text = 'Interbase');
	if (cbDatabaseType.Text <> '') then begin
		cbVersions.Enabled := true;

 		if (cbDatabaseType.Text = 'MSSQL') then
			cConnectorType := frConfMSSQL.GetConnectorName
		else if (cbDatabaseType.Text = 'Interbase') then
			cConnectorType := frConfInterbase.GetConnectorName;

		dmLogsAndSettings.CcConfigStorage.Edit;
		ConnectionConfig.DBType := cbDatabaseType.Text;
		ConnectionConfig.ConnectorName := cConnectorType;
		cbVersions.Items.Assign(ConnectionConfig.Connection.DBAdaptor.SupportedVersions);
	end
	else
		cbVersions.Enabled := false;
end;

procedure TfrConfServer.cbVersionsChange(Sender: TObject);
var
	lIsSelected: boolean;
begin
	lIsSelected := cbVersions.Text <> '';
	SetEnableControls(lIsSelected);
end;

procedure TfrConfServer.mDBParamsDBTypeChange(Sender: TField);
begin
//  RefreshVersions;
  mDBParamsDBChange(Sender);
end;

procedure TfrConfServer.cbDatabaseTypeChange(Sender: TObject);
begin
  RefreshVersions;
  if not LoadingParams then begin
    //After changing the DBType, we must reload the connection parameters,
    //since a new underlying connection object has been created
    ReloadParams;
  end;
end;

end.
