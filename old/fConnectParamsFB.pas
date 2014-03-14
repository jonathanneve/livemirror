unit fConnectParamsFB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Comp.Client, Data.DB, CcProviders, CcProvFireDAC, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, Vcl.StdCtrls, Vcl.Buttons, config, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI;

type
  TfrConnectParamsFB = class(TFrame, ILMConnectionFrame)
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    SpeedButton2: TSpeedButton;
    Label10: TLabel;
    edDBName: TEdit;
    edUserName: TEdit;
    edPassword: TEdit;
    cbDialect: TComboBox;
    edCharset: TEdit;
    edClientDLL: TEdit;
    cbVersions: TComboBox;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    OpenDialogDLL: TFileOpenDialog;
    OpenDialog: TFileOpenDialog;
    Connection: TCcConnectionFireDAC;
    FDConnection: TFDConnection;
    FDTransaction1: TFDTransaction;
    btTest: TButton;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btTestClick(Sender: TObject);
  private
  public
    procedure SetName(cName: String);
    function GetDBType: String;
    procedure Init(parentCtrl: TWinControl);
    procedure Save(configFileName: String);
    procedure Load(configFileName: String);
    procedure SetConnectParams;
    constructor Create(AOwner: TComponent);override;
  end;

implementation

{$R *.dfm}

uses IniFiles, gnugettext;

procedure TfrConnectParamsFB.SetName(cName: String);
begin
  Name := 'frConnectParamsFB' + cName;
end;

procedure TfrConnectParamsFB.Load(configFileName: String);
var
  ini : TIniFile;
begin
  ini := TIniFile.Create(configFileName);
  try
    cbVersions.ItemIndex := cbVersions.Items.IndexOf(ini.ReadString('General', 'DBVersion', 'FB2.5'));
    edDBName.Text := ini.ReadString('General', 'DBName', '');
    edUserName.Text := ini.ReadString('General', 'Username', '');
    edPassword.Text := ini.ReadString('General', 'Password', '');
    cbDialect.ItemIndex := cbDialect.Items.IndexOf(ini.ReadString('General', 'SQLDialect', '3'));
    edClientDLL.Text := ini.ReadString('General', 'Clientdll', 'fbclient.dll');
  finally
    ini.Free;
  end;
end;

procedure TfrConnectParamsFB.btTestClick(Sender: TObject);
begin
  SetConnectParams;
  Connection.Connect;
  Connection.Disconnect;
  ShowMessage(_('Connection established successfully'));
end;

constructor TfrConnectParamsFB.Create(AOwner: TComponent);
begin
  inherited;
  TranslateComponent(Self);
end;

function TfrConnectParamsFB.GetDBType: String;
begin
  Result := Connection.DBType;
end;

procedure TfrConnectParamsFB.Init(parentCtrl: TWinControl);
begin
  parent := parentCtrl;
  Align := alClient;
  cbVersions.Items.Assign(Connection.DBAdaptor.SupportedVersions);
end;
  
procedure TfrConnectParamsFB.Save(configFileName: String);
var
  ini : TIniFile;
begin
  ini := TIniFile.Create(configFileName);
  try
    ini.WriteString('General', 'DBVersion', cbVersions.Text);
    ini.WriteString('General', 'DBName', edDBName.Text);
    ini.WriteString('General', 'Username', edUserName.Text);
    ini.WriteString('General', 'Password', edPassword.Text);
    ini.WriteString('General', 'SQLDialect', cbDialect.Text);
    ini.WriteString('General', 'Clientdll', edClientDLL.Text);
  finally
    ini.Free;
  end;
end;

procedure TfrConnectParamsFB.SetConnectParams;
begin
  Connection.DBVersion := cbVersions.Text;
  FDConnection.DriverName := 'FB';
  FDConnection.Params.Values['Database'] := Trim(edDBName.Text);
  FDConnection.Params.Values['User_Name'] := Trim(edUserName.Text);
  FDConnection.Params.Values['Password'] := Trim(edPassword.Text);
  FDConnection.Params.Values['SQLDialect'] := cbDialect.Text;
  if Trim(edClientDLL.Text) <> '' then
    FDPhysFBDriverLink.VendorLib := edClientDLL.Text
  else
    FDPhysFBDriverLink.VendorLib := '';
end;

procedure TfrConnectParamsFB.SpeedButton1Click(Sender: TObject);
begin
  if (OpenDialog.Execute) then
    edDBName.Text := OpenDialog.FileName;
end;

procedure TfrConnectParamsFB.SpeedButton2Click(Sender: TObject);
begin
  if (OpenDialogDLL.Execute) then
    edClientDLL.Text := OpenDialogDLL.FileName;
end;

end.
