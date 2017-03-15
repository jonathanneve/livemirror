unit dFireDAC;

interface

uses
  System.SysUtils, System.Classes, dconfig, CcProviders, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Moni.Base,
  FireDAC.Moni.FlatFile, CcProvFireDAC, FireDAC.Comp.Client, Data.DB,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, FireDAC.Phys.MySQL,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLite, CcProvFDSQLite,
  FireDAC.Phys.SQLiteWrapper;

type
  TdmFireDAC = class(TDataModule, ILMNode)
    FDConnection: TFDConnection;
    FDTransaction: TFDTransaction;
    CcConnection: TCcConnectionFireDAC;
    FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    CcConnectionSQLite: TCcConnectionFDSQLite;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDSQLiteFunction1: TFDSQLiteFunction;
    FDSQLiteRTree1: TFDSQLiteRTree;
  private
    FNodeType: String;
    FdmConfig: TdmConfig;
    FDBType: string;
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

uses System.IniFiles, LMUtils, uLkJSON;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmFireDAC }

constructor TdmFireDAC.Create(AOwner: TComponent; databaseType: String);
begin
  inherited Create(AOwner);
  FDBType := databaseType;
  GetConnection.DBType := databaseType;
  FDConnection.Params.Clear;
  FDConnection.DriverName := DriverName;
end;

function TdmFireDAC.GetConnection: TCcConnection;
begin
  if DBType = 'SQLite' then
    Result := CcConnectionSQLite
  else
    Result := CcConnection;
end;

function TdmFireDAC.GetDBType: string;
begin
  Result := FDBType;
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
    Result := 'PG'
  else if DBType = 'SQLite' then
    Result := 'SQLite';
end;

function TdmFireDAC.GetNodeType: String;
begin
  Result := FNodeType;
end;

procedure TdmFireDAC.Load(dmConfig: TdmConfig; nodeType: String);
var
  ini : TIniFile;
  cClientDLL, configFile: String;
  I: Integer;
  db: TlkJSONobject;
  fd: TlkJSONobject;
begin
  FNodeType := nodeType;
  FdmConfig := dmConfig;

  if FdmConfig.ConfigName = '' then
    Exit;

  if FdmConfig.ConfigSource = csIniFile then begin
    configFile := GetLiveMirrorRoot + 'Configs\' + FdmConfig.ConfigName + '\' + FNodeType + '.ini';;
    if not FileExists(configFile) then
      Exit;

    ini := TIniFile.Create(configFile);
    try
      ini.ReadSectionValues('FireDAC', FDConnection.Params);
      GetConnection.DBType := DBType;
      GetConnection.DBVersion := ini.ReadString('General', 'DBVersion', '');
      {$IFDEF DEBUG}
      FDConnection.Params.Values['MonitorBy'] := 'FlatFile';
      FDMoniFlatFileClientLink.Tracing := False;
      FDMoniFlatFileClientLink.FileName := ExtractFileDir(configFile) + '\debug.txt';
  //    FDMoniFlatFileClientLink.Tracing := True;
      {$ENDIF}
    finally
      ini.Free;
    end;
  end
  else begin
    if (FdmConfig.ConfigJSON.Field[FNodeType + 'DB'] <> nil) then begin
      db := FdmConfig.ConfigJSON.Field[FNodeType + 'DB'] as TlkJSONobject;
      GetConnection.DBType := DBType;
      GetConnection.DBVersion := db.Field['DBVersion'].Value;
      if db.Field['FireDAC'] <> nil then
        fd := db.Field['FireDAC'] as TlkJSONobject;

      for I := 0 to fd.Count do begin
        FDConnection.Params.Values[fd.NameOf[i]] := fd.FieldByIndex[i].Value;
      end;
    end;
  end;
end;

procedure TdmFireDAC.Save;
var
  ini : TIniFile;
  configFile: String;
  I: Integer;
  cName: string;
begin
  if FdmConfig.ConfigSource = csIniFile then begin
    configFile := GetLiveMirrorRoot + 'Configs\' + FdmConfig.ConfigName + '\' + FNodeType + '.ini';;
    ini := TIniFile.Create(configFile);
    try
      ini.WriteString('General', 'DBVersion', GetConnection.DBVersion);
      for I := 0 to FDConnection.Params.Count - 1 do begin
        cName := FDConnection.Params.Names[i];
        ini.WriteString('FireDAC', cName, FDConnection.Params.Values[cName]);
      end;
    finally
      ini.Free;
    end;
  end
  else begin
{    FdmConfig.ConfigJSON.
    ini.WriteString('General', 'DBVersion', GetConnection.DBVersion);
    for I := 0 to FDConnection.Params.Count - 1 do begin
      cName := FDConnection.Params.Names[i];
      ini.WriteString('FireDAC', cName, FDConnection.Params.Values[cName]);
    end;}
  end;
end;

end.
