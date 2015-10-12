unit dFireDAC;

interface

uses
  System.SysUtils, System.Classes, dconfig, CcProviders, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Moni.Base,
  FireDAC.Moni.FlatFile, CcProvFireDAC, FireDAC.Comp.Client, Data.DB,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, FireDAC.Phys.MySQL;

type
  TdmFireDAC = class(TDataModule, ILMNode)
    FDConnection: TFDConnection;
    FDTransaction: TFDTransaction;
    CcConnection: TCcConnectionFireDAC;
    FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
  private
    FNodeType: String;
    FdmConfig: TdmConfig;
    function GetDriverName: String;
    function GetDBType: string;
  public
    constructor Create(AOwner: TComponent; databaseType: String);
    function GetNodeType: String;
    procedure Load(dmConfig: TdmConfig; nodeType: String);
    procedure Save;
    function GetConnection: TCcConnection;
    function GetDescription: String;
    property DBType: string read GetDBType;
    property DriverName: String read GetDriverName;
  end;

var
  dmFireDAC: TdmFireDAC;

implementation

uses System.IniFiles, LMUtils;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmFireDAC }

constructor TdmFireDAC.Create(AOwner: TComponent; databaseType: String);
begin
  inherited Create(AOwner);
  CcConnection.DBType := databaseType;
  FDConnection.Params.Clear;
  FDConnection.DriverName := DriverName;
end;

function TdmFireDAC.GetConnection: TCcConnection;
begin
  Result := CcConnection;
end;

function TdmFireDAC.GetDBType: string;
begin
  Result := CcConnection.DBType;
end;

function TdmFireDAC.GetDescription: String;
begin
  Result := FDConnection.ConnectionString;
end;

function TdmFireDAC.GetDriverName: String;
begin
  if DBType = 'MSSQL' then
    Result := 'MSSQL'
  else if DBType = 'MySQL' then
    Result := 'MySQL'
  else if DBType = 'Oracle' then
    Result := 'Ora'
  else if DBType = 'Postgres' then
    Result := 'PG';
end;

function TdmFireDAC.GetNodeType: String;
begin
  Result := FNodeType;
end;

procedure TdmFireDAC.Load(dmConfig: TdmConfig; nodeType: String);
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
    CcConnection.DBType := DBType;
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

procedure TdmFireDAC.Save;
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
