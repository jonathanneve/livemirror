unit fConfServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzCmboBx, RzDBCmbo, Mask, RzEdit, RzDBEdit, ExtCtrls,
  RzPanel, Buttons, RzShellDialogs, CcConfStorage, DB, CcMemDS,
  fConfInterbase, fConfMSSQL, DBCtrls;

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
    Label3: TLabel;
    SpeedButton1: TSpeedButton;
    Label9: TLabel;
    edLocalSYSDBAName: TRzDBEdit;
    edLocalSYSDBAPassword: TRzDBEdit;
    edLocalDBName: TRzDBEdit;
    edLocalCharset: TRzDBEdit;
    edVersions: TRzDBComboBox;
    Label1: TLabel;
    Label2: TLabel;
    edRoleName: TRzDBEdit;
    frConfMSSQL: TfrConfMSSQL;
    DBText1: TDBText;
    frConfInterbase: TfrConfInterbase;
    procedure SpeedButton1Click(Sender: TObject);
    procedure mDBParamsDBNameChange(Sender: TField);
  private
    ConnectionConfig: TCcConnectionConfig;
    FieldChanging, LoadingParams: Boolean;
  public
    ControlsEnabled: Boolean;
    procedure DisableControls;
    procedure EnableControls;
    procedure LoadParams(cnxConf: TCcConnectionConfig);
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
  end;

implementation

uses dLogsAndSettings;

{$R *.dfm}

procedure TfrConfServer.SpeedButton1Click(Sender: TObject);
begin
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
  frConfMSSQL.Visible := (ConnectionConfig.DBType = 'MSSQL');
  frConfInterbase.Visible := (ConnectionConfig.DBType = 'Interbase');
  edVersions.Items.Assign(ConnectionConfig.Connection.DBAdaptor.SupportedVersions);

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

procedure TfrConfServer.mDBParamsDBNameChange(Sender: TField);
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
begin
  inherited;
  ControlsEnabled := True;
end;

procedure TfrConfServer.EnableControls;
begin
  pnConnectParams.Enabled := True;
  frConfMSSQL.pnMSSQL.Enabled := True;
  frConfInterbase.pnInterbase.Enabled := True;
  ControlsEnabled := True;
end;

procedure TfrConfServer.DisableControls;
begin
  pnConnectParams.Enabled := False;
  frConfMSSQL.pnMSSQL.Enabled := False;
  frConfInterbase.pnInterbase.Enabled := False;
  ControlsEnabled := False;
end;

end.
