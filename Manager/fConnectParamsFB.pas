unit fConnectParamsFB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Comp.Client, Data.DB, CcProviders, CcProvFireDAC, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, Vcl.StdCtrls, Vcl.Buttons, config, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, dconfig;

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
    FDPhysFBDriverLinkOld: TFDPhysFBDriverLink;
    OpenDialogDLL: TOpenDialog;
    OpenDialog: TOpenDialog;
    ConnectionOld: TCcConnectionFireDAC;
    FDConnectionOld: TFDConnection;
    FDTransaction1Old: TFDTransaction;
    btTest: TButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btTestClick(Sender: TObject);
  private
    FNode: ILMNode;
    procedure LoadFromNode;

  public
    function GetNode: ILMNode;
    procedure SetNode(n: ILMNode);
    procedure SaveToNode;
    procedure Init(parentCtrl: TWinControl);
    constructor Create(AOwner: TComponent);override;
    procedure FreeFrame;
  end;

implementation

{$R *.dfm}

uses IniFiles, gnugettext, dInterbase;

procedure TfrConnectParamsFB.SetNode(n: ILMNode);
begin
  FNode := n;
  Name := 'frConnectParamsFB_' + n.NodeType;
  LoadFromNode;
end;

procedure TfrConnectParamsFB.btTestClick(Sender: TObject);
begin
  SaveToNode;
  FNode.Connection.Connect;
  FNode.Connection.Disconnect;
  ShowMessage(_('Connection established successfully'));
end;

procedure TfrConnectParamsFB.FreeFrame;
begin
  Parent := nil;
  Free;
end;

constructor TfrConnectParamsFB.Create(AOwner: TComponent);
begin
  inherited;
  TranslateComponent(Self);
end;

function TfrConnectParamsFB.GetNode: ILMNode;
begin
  Result := FNode;
end;

procedure TfrConnectParamsFB.Init(parentCtrl: TWinControl);
begin
  parent := parentCtrl;
  Align := alClient;
end;

procedure TfrConnectParamsFB.LoadFromNode;
begin
  cbVersions.Items.Assign(FNode.Connection.DBAdaptor.SupportedVersions);
  with FNode as TdmInterbase do begin
    cbVersions.ItemIndex := cbVersions.Items.IndexOf(CcConnection.DBVersion);
    edDBName.Text := FDConnection.Params.Values['Database'];
    edUserName.Text := FDConnection.Params.Values['User_Name'];
    edPassword.Text := FDConnection.Params.Values['Password'];
    cbDialect.ItemIndex := cbDialect.Items.IndexOf(FDConnection.Params.Values['SQLDialect']);

    if FDConnection.DriverName = 'IB' then
      edClientDLL.Text := FDPhysIBDriverLink.VendorLib
    else
      edClientDLL.Text := FDPhysFBDriverLink.VendorLib;
  end;
end;

procedure TfrConnectParamsFB.SaveToNode;
begin
  with FNode as TdmInterbase do begin
    FDConnection.DriverName := 'FB';
    CcConnection.DBVersion := cbVersions.Text;
    CcConnection.ConnectionParams.Values['Database'] := Trim(edDBName.Text);
    CcConnection.FDConnection.Params.Values['User_Name'] := Trim(edUserName.Text);
    CcConnection.FDConnection.Params.Values['Password'] := Trim(edPassword.Text);
    CcConnection.FDConnection.Params.Values['SQLDialect'] := cbDialect.Text;
    if Trim(edClientDLL.Text) <> '' then
      FDPhysFBDriverLink.VendorLib := edClientDLL.Text
    else
      FDPhysFBDriverLink.VendorLib := '';
  end;
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
