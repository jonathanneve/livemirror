unit dInterbase;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, FireDAC.Phys.FB, FireDAC.Phys.IBBase, FireDAC.Phys.IB,
  FireDAC.Comp.Client, Data.DB, CcProviders, CcProvFireDAC, main;

type
  TdmInterbase = class(TDataModule, ILMNode)
    FDConnection: TFDConnection;
    FDTransaction: TFDTransaction;
    FDPhysIBDriverLink: TFDPhysIBDriverLink;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    CcConnection: TCcConnectionFireDAC;
  private
    { Déclarations privées }
  public
    procedure Load(configFileName: String);
    function GetConnection: TCcConnection;
    function GetDescription: String;
  end;

var
  dmInterbase: TdmInterbase;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  IniFiles, LMUtils, gnugettext;

{ TdmInterbase }

function TdmInterbase.GetConnection: TCcConnection;
begin
  Result := CcConnection;
end;

function TdmInterbase.GetDescription: String;
begin
  Result := FDConnection.Params.Values['Database'] + ' (' + FDConnection.DriverName + ')';
end;

procedure TdmInterbase.Load(configFileName: String);
var
  ini : TIniFile;
  cClientDLL: String;
begin
  ini := TIniFile.Create(configFileName);
  try
    CcConnection.DBVersion := ini.ReadString('General', 'DBVersion', 'FB2.5');
    FDConnection.DriverName := Copy(CcConnection.DBVersion, 1, 2); //FB or IB
    FDConnection.Params.Values['Database'] := ini.ReadString('General', 'DBName', '');
    FDConnection.Params.Values['User_Name'] := ini.ReadString('General', 'Username', '');
    FDConnection.Params.Values['Password'] := ini.ReadString('General', 'Password', '');
    FDConnection.Params.Values['SQLDialect'] := ini.ReadString('General', 'SQLDialect', '3');
    cClientDLL := ini.ReadString('General', 'Clientdll', '');
    if FDConnection.DriverName = 'IB' then
      FDPhysIBDriverLink.VendorLib := cClientDLL
    else
      FDPhysFBDriverLink.VendorLib := cClientDLL;
  finally
    ini.Free;
  end;
end;

end.
