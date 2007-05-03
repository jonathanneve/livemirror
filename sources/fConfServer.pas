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
		OpenDialog: TRzOpenDialog;
		mDBParams: TCcMemoryData;
		mDBParamsDBName: TStringField;
		mDBParamsUserLogin: TStringField;
		mDBParamsUserPassword: TStringField;
		mDBParamsCharset: TStringField;
		mDBParamsRoleName: TStringField;
		mDBParamsDBVersion: TStringField;
		mDBParamsDS: TDataSource;
		mDBParamsClientDLL: TStringField;
		mDBParamsSQLDialect: TIntegerField;
		mDBParamsConnectionString: TStringField;
		mDBParamsADOConnectionTimeout: TIntegerField;
		mDBParamsADOQueryTimeout: TIntegerField;
		Panel1: TRzPanel;
		Label5: TLabel;
		Label6: TLabel;
		Label4: TLabel;
		Label9: TLabel;
		edLocalSYSDBAName: TRzDBEdit;
		edLocalSYSDBAPassword: TRzDBEdit;
		edLocalDBName: TRzDBEdit;
		edLocalCharset: TRzDBEdit;
		Label2: TLabel;
		edRoleName: TRzDBEdit;
		frConfMSSQL: TfrConfMSSQL;
		frConfInterbase: TfrConfInterbase;
		mDBParamsDBType: TStringField;
		RzPanel1: TRzPanel;
		Label3: TLabel;
		Label1: TLabel;
		cbVersions: TRzDBComboBox;
		cbDatabaseType: TRzDBComboBox;
    btBrowseDB: TBitBtn;
		procedure btBrowseDBClick(Sender: TObject);
		procedure mDBParamsDBChange(Sender: TField);
		procedure cbDatabaseTypeChange(Sender: TObject);
		procedure cbVersionsChange(Sender: TObject);
	private
		ConnectionConfig: TCcConnectionConfig;
		FieldChanging, LoadingParams: Boolean;
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
	StrUtils,
	dLogsAndSettings;

{$R *.dfm}

procedure TfrConfServer.btBrowseDBClick(Sender: TObject);
var
	Value: string;
begin
	// seek correct filter
	Value := mDBParamsDS.DataSet.FieldByName('DBVersion').AsString;
	if (AnsiContainsStr(Value, 'IB')) then
		OpenDialog.FilterIndex := 1
	else if (AnsiContainsStr(Value, 'FB')) then
		OpenDialog.FilterIndex := 2
	else
		OpenDialog.FilterIndex := 3;

	if OpenDialog.Execute then begin
		mDBParams.Edit;
		mDBParamsDBName.AsString := OpenDialog.FileName;
	end;
end;

procedure TfrConfServer.LoadParams(cnxConf: TCcConnectionConfig);
var
	i : Integer;
	cFieldName: String;
begin
	ConnectionConfig := cnxConf;

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

procedure TfrConfServer.cbDatabaseTypeChange(Sender: TObject);
var
	cConnectorType: string;
begin
	frConfMSSQL.Visible := (cbDatabaseType.Text = 'MSSQL');
	frConfInterbase.Visible := (cbDatabaseType.Text = 'Interbase');

	if (cbDatabaseType.Text <> '') then begin
		cbVersions.Enabled := true;

		if (cbDatabaseType.Text = 'MSSQL') then
			cConnectorType := 'ADO'
		else if (cbDatabaseType.Text = 'Interbase') then
			cConnectorType := 'FIB';

		dmLogsAndSettings.CcConfigStorage.Edit;
		ConnectionConfig.DBType := cbDatabaseType.Text;
		ConnectionConfig.ConnectorName := cConnectorType;
		cbVersions.Clear();
		mDBParamsDS.DataSet.FieldByName('DBVersion').AsString := '';

		cbVersions.Items.Assign(ConnectionConfig.Connection.DBAdaptor.SupportedVersions);
	end
	else begin
		cbVersions.Enabled := true;
	end;
end;

procedure TfrConfServer.cbVersionsChange(Sender: TObject);
var
	lIsSelected: boolean;
begin
	lIsSelected := cbVersions.Text <> '';
	SetEnableControls(lIsSelected);
end;

end.
