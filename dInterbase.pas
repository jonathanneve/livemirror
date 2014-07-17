unit dInterbase;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, FireDAC.Phys.FB, FireDAC.Phys.IBBase, FireDAC.Phys.IB,
  FireDAC.Comp.Client, Data.DB, CcProviders, CcProvFireDAC, main,
  FireDAC.Moni.Base, FireDAC.Moni.FlatFile, dconfig;

type
  TdmInterbase = class(TDataModule, ILMNode)
    FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink;
    FDConnection: TFDConnection;
    FDTransaction: TFDTransaction;
    FDPhysIBDriverLink: TFDPhysIBDriverLink;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    CcConnection: TCcConnectionFireDAC;
  private
    FNodeType: String;
    FConfigFileName: string;
  public
    function GetNodeType: String;
    procedure Load(configDir: String; nodeType: String);
    procedure Save;
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

function TdmInterbase.GetNodeType: String;
begin
  Result := FNodeType;
end;

procedure TdmInterbase.Load(configDir: String; nodeType: String);
var
  ini : TIniFile;
  cClientDLL: String;
begin
  FNodeType := nodeType;
  FConfigFileName := configDir + nodeType + '.ini';
  if not FileExists(FConfigFileName) then
    Exit;

  ini := TIniFile.Create(FConfigFileName);
  try
    CcConnection.DBVersion := ini.ReadString('General', 'DBVersion', 'FB2.5');
    FDConnection.DriverName := Copy(CcConnection.DBVersion, 1, 2); //FB or IB
    FDConnection.Params.Values['Database'] := ini.ReadString('General', 'DBName', '');
    FDConnection.Params.Values['User_Name'] := ini.ReadString('General', 'Username', '');
    FDConnection.Params.Values['Password'] := ini.ReadString('General', 'Password', '');
    FDConnection.Params.Values['SQLDialect'] := ini.ReadString('General', 'SQLDialect', '3');
    {$IFDEF DEBUG}
    FDConnection.Params.Values['MonitorBy'] := 'FlatFile';
    FDMoniFlatFileClientLink.FileName := ExtractFileDir(FConfigFileName) + '\debug.txt';
    FDMoniFlatFileClientLink.Tracing := True;
    {$ENDIF}

    cClientDLL := ini.ReadString('General', 'Clientdll', '');
    if FDConnection.DriverName = 'IB' then
      FDPhysIBDriverLink.VendorLib := cClientDLL
    else
      FDPhysFBDriverLink.VendorLib := cClientDLL;
  finally
    ini.Free;
  end;
end;

procedure TdmInterbase.Save;
var
  ini : TIniFile;
begin
  ini := TIniFile.Create(FConfigFileName);
  try
    ini.WriteString('General', 'DBVersion', CcConnection.DBVersion);
    ini.WriteString('General', 'DBName', FDConnection.Params.Values['Database']);
    ini.WriteString('General', 'Username', FDConnection.Params.Values['User_Name']);
    ini.WriteString('General', 'Password', FDConnection.Params.Values['Password']);
    ini.WriteString('General', 'SQLDialect', FDConnection.Params.Values['SQLDialect']);

    if FDConnection.DriverName = 'IB' then
      ini.WriteString('General', 'Clientdll', FDPhysIBDriverLink.VendorLib)
    else
      ini.WriteString('General', 'Clientdll', FDPhysFBDriverLink.VendorLib);
  finally
    ini.Free;
  end;
end;

end.
