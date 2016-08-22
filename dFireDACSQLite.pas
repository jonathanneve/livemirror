unit dFireDACSQLite;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.VCLUI.Wait, FireDAC.Stan.ExprFuncs, CcProviders, CcProvFireDAC,
  CcProvFDSQLite, FireDAC.Phys.SQLite, FireDAC.Comp.UI, FireDAC.Moni.Base,
  FireDAC.Moni.FlatFile, FireDAC.Comp.Client, Data.DB, dConfig;

type
  TdmFireDACSQLite = class(TDataModule, ILMNode)
    FDConnection: TFDConnection;
    FDTransaction: TFDTransaction;
    FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    CcConnection: TCcConnectionFDSQLite;
  private
    FNodeType: String;
    FdmConfig: TdmConfig;
  public
    function GetNodeType: String;
    procedure Load(dmConfig: TdmConfig; nodeType: String);
    procedure Save;
    function GetConnection: TCcConnection;
    function GetDescription: String;
    constructor Create(AOwner: TComponent);
  end;

var
  dmFireDACSQLite: TdmFireDACSQLite;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses System.IniFiles, LMUtils;

constructor TdmFireDACSQLite.Create(AOwner: TComponent);
begin
  inherited;
  FDConnection.Params.Clear;
  FDConnection.DriverName := 'SQLite';
end;

function TdmFireDACSQLite.GetConnection: TCcConnection;
begin
  Result := CcConnection;
end;

function TdmFireDACSQLite.GetDescription: String;
begin
  Result := FDConnection.ConnectionString;
end;

function TdmFireDACSQLite.GetNodeType: String;
begin
  Result := FNodeType;
end;

procedure TdmFireDACSQLite.Load(dmConfig: TdmConfig; nodeType: String);
var
  ini : TIniFile;
  cClientDLL, configFile: String;
begin
  FNodeType := nodeType;
  FdmConfig := dmConfig;

  if FdmConfig.ConfigName = '' then
    Exit;

  configFile := GetLiveMirrorRoot + 'Configs\' + FdmConfig.ConfigName + '\' + FNodeType + '.ini';;
  if not FileExists(configFile) then
    Exit;

  ini := TIniFile.Create(configFile);
  try
    ini.ReadSectionValues('FireDAC', FDConnection.Params);
    CcConnection.DBType := 'SQLite';
    CcConnection.DBVersion := ini.ReadString('General', 'DBVersion', '');
    {$IFDEF DEBUG}
    FDConnection.Params.Values['MonitorBy'] := 'FlatFile';
    FDMoniFlatFileClientLink.FileName := ExtractFileDir(configFile) + '\debug.txt';
    FDMoniFlatFileClientLink.Tracing := True;
    {$ENDIF}
  finally
    ini.Free;
  end;
end;

procedure TdmFireDACSQLite.Save;
var
  ini : TIniFile;
  configFile: String;
  I: Integer;
  cName: string;
begin
  configFile := GetLiveMirrorRoot + 'Configs\' + FdmConfig.ConfigName + '\' + FNodeType + '.ini';;
  ini := TIniFile.Create(configFile);
  try
    ini.WriteString('General', 'DBVersion', CcConnection.DBVersion);
    for I := 0 to FDConnection.Params.Count - 1 do begin
      cName := FDConnection.Params.Names[i];
      ini.WriteString('FireDAC', cName, FDConnection.Params.Values[cName]);
    end;
  finally
    ini.Free;
  end;
end;


end.
