unit fConnectParamsFireDAC;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Comp.Client, Data.DB, CcProviders, CcProvFireDAC,
  FireDAC.Phys.IBBase, Vcl.StdCtrls, Vcl.Buttons, dConfig;

type
  TfrConnectParamsFireDAC = class(TFrame, ILMConnectionFrame)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edDBName: TEdit;
    edUserName: TEdit;
    edPassword: TEdit;
    btTest: TButton;
    edServerName: TEdit;
    Label5: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
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

uses dFireDAC, FireDAC.VCLUI.ConnEdit, gnugettext;

procedure TfrConnectParamsFireDAC.btTestClick(Sender: TObject);
begin
  SaveToNode;
  FNode.Connection.Connect;
  FNode.Connection.Disconnect;
  ShowMessage(_('Connection established successfully'));
end;

procedure TfrConnectParamsFireDAC.Button1Click(Sender: TObject);
var
  sConnStr: String;
begin
  SaveToNode;
  with fNode as TdmFireDAC do begin
    sConnStr := FDConnection.ResultConnectionDef.BuildString();
    if TfrmFDGUIxFormsConnEdit.Execute(sConnStr, _('Database connection setup'), Format(_('Setup database connection parameters for your %s database'), [_(fNode.NodeType)])) then begin
      FDConnection.ResultConnectionDef.ParseString(sConnStr);
      LoadFromNode;
    end;
  end;
end;

constructor TfrConnectParamsFireDAC.Create(AOwner: TComponent);
begin
  inherited;
  TranslateComponent(Self);
end;

procedure TfrConnectParamsFireDAC.FreeFrame;
begin
  Parent := nil;
  Free;
end;

function TfrConnectParamsFireDAC.GetNode: ILMNode;
begin
  Result := FNode;
end;

procedure TfrConnectParamsFireDAC.Init(parentCtrl: TWinControl);
begin
  parent := parentCtrl;
  Align := alClient;
end;

procedure TfrConnectParamsFireDAC.LoadFromNode;
begin
  with FNode as TdmFireDAC do begin
    edDBName.Text := FDConnection.Params.Values['Database'];
    edUserName.Text := FDConnection.Params.Values['User_Name'];
    edPassword.Text := FDConnection.Params.Values['Password'];
    edServerName.Text := FDConnection.Params.Values['Server'];
  end;
end;

procedure TfrConnectParamsFireDAC.SaveToNode;
begin
  with FNode as TdmFireDAC do begin
    CcConnection.DBVersion := FNode.Connection.DBAdaptor.SupportedVersions[0];
    FDConnection.DriverName := DriverName;
    CcConnection.ConnectionParams.Values['Database'] := Trim(edDBName.Text);
    CcConnection.ConnectionParams.Values['User_Name'] := Trim(edUserName.Text);
    CcConnection.ConnectionParams.Values['Password'] := Trim(edPassword.Text);
    CcConnection.ConnectionParams.Values['Server'] := edServerName.Text;
  end;
end;

procedure TfrConnectParamsFireDAC.SetNode(n: ILMNode);
begin
  FNode := n;
  Name := 'frConnectParamsFireDAC_' + n.NodeType;
  LoadFromNode;
end;

end.
