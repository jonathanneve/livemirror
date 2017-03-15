unit dconfig;

interface

uses
  System.SysUtils, System.Classes, CcConf, IniFiles, CcProviders,
  Vcl.Controls, gnugettext, errors;

type
  TdmConfig = class;

  ILMNode = interface['{F9C5A7A6-C810-4C96-8D23-A35F004DB262}']
    function GetConnection: TCcConnection;
    function GetDescription: String;
    function GetNodeType: String;
    procedure Load(dmConfig: TdmConfig; nodeType: String);
    procedure Save;
    property NodeType: String read GetNodeType;
    property Description: String read GetDescription;
    property Connection: TCcConnection read GetConnection;
  end;

  ILMConnectionFrame = interface['{E67ED917-1575-4159-B547-35CCD40881A9}']
    procedure Init(parentCtrl: TWinControl);
    procedure SaveToNode;
    function GetNode: ILMNode;
    procedure SetNode(n: ILMNode);
    procedure FreeFrame;

    property Node : ILMNode read GetNode write SetNode;
  end;

  TLMIniFile = class(TInifile)
    function ReadString(const Section, Ident, Default: string): string; override;
  end;

  TdmConfig = class(TDataModule)
    MasterConfig: TCcConfig;
    MirrorConfig: TCcConfig;
  private
    ConfigsIni: TLMIniFile;
    FLicence: String;
    FExcludedTables: String;
    FSyncFrequency: Integer;
    FMasterDBType: String;
    FMirrorDBType: String;
    FMirrorNode: ILMNode;
    FMasterNode: ILMNode;
    FConfigName: string;
    FMetaDataCreated: Boolean;
    FRootDir: String;
    FTrackChanges :Boolean;
    FOnMasterDBTypeChanged: TNotifyEvent;
    FOnMirrorDBTypeChanged: TNotifyEvent;
    FMirrorExcludedFields, FMasterExcludedFields: TStringList;
    FErrorConfig: TCcErrorConfigFile;
    FExcludedFields: String;
    procedure SaveLoadConfig(save: Boolean);
    procedure SetMasterDBType(const Value: String);
    procedure SetMirrorDBType(const Value: String);
    function GetNode(dbType, nodeType: String): ILMNode;
    procedure ConfigureMaster;
    procedure ConfigureMirror;
    procedure RemoveConfigurationFromMaster;
    procedure RemoveConfigurationFromMirror;
    function GetMasterDBTypeDescription: String;
    function GetMirrorDBTypeDescription: String;
    function DBTypeDescription(dbType: String): String;
    function GetErrorConfig: TCcErrorConfigFile;
  public
    procedure ExcludeKeywordFieldNames(FieldList : TStringList);
    property ExcludedTables : String read FExcludedTables write FExcludedTables;
    property ExcludedFields : String read FExcludedFields write FExcludedFields;
    property Licence : String read FLicence write FLicence;
    property SyncFrequency : Integer read FSyncFrequency write FSyncFrequency;
    property TrackChanges : Boolean read FTrackChanges write FTrackChanges;
    property MasterNode: ILMNode read FMasterNode;
    property MirrorNode: ILMNode read FMirrorNode;
    property MasterDBType: String read FMasterDBType write SetMasterDBType;
    property MirrorDBType: String read FMirrorDBType write SetMirrorDBType;
    property MasterDBTypeDescription: String read GetMasterDBTypeDescription;
    property MirrorDBTypeDescription: String read GetMirrorDBTypeDescription;
    property MetaDataCreated: Boolean read FMetaDataCreated write FMetaDataCreated;
    property ConfigName: String read FConfigName write FConfigName;
    property OnMasterDBTypeChanged: TNotifyEvent read FOnMasterDBTypeChanged write FOnMasterDBTypeChanged;
    property OnMirrorDBTypeChanged: TNotifyEvent read FOnMirrorDBTypeChanged write FOnMirrorDBTypeChanged;
    function DBTypeByDescription(desc: string): String;
    property ErrorConfig :TCcErrorConfigFile read GetErrorConfig;

    procedure LoadConfig(cConfigName: String);
    procedure SaveConfig;
    procedure ConfigureNodes;
    procedure RemoveConfigurationFromNodes;
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses dInterbase, LMUtils, dFireDAC, Windows;

{$R *.dfm}

function TLMIniFile.ReadString(const Section, Ident, Default: string): string;
var
  Buffer: array[0..5000] of Char;
begin
  SetString(Result, Buffer, GetPrivateProfileString(MarshaledString(Section),
    MarshaledString(Ident), MarshaledString(Default), Buffer, Length(Buffer),
    MarshaledString(FileName)));
end;

procedure TdmConfig.SaveConfig;
begin
  SaveLoadConfig(true);
end;

procedure TdmConfig.SaveLoadConfig(save: Boolean);
var
  cConfigDir : String;

  procedure DoSaveConfig;
  begin
    ConfigsIni.WriteString(FConfigName, 'ExcludedTables', FExcludedTables);
    ConfigsIni.WriteString(FConfigName, 'ExcludedFields', FExcludedFields);
    ConfigsIni.WriteString(FConfigName, 'SyncFrequency', IntToStr(FSyncFrequency));
    ConfigsIni.WriteBool(FConfigName, 'TrackChanges', FTrackChanges);
    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    ConfigsIni.WriteString(FConfigName, 'Licence', FLicence);
    {$ENDIF}
    {$ENDIF}
    ConfigsIni.WriteString(FConfigName, 'MasterDBType', FMasterDBType);
    ConfigsIni.WriteString(FConfigName, 'MirrorDBType', FMirrorDBType);
    ConfigsIni.WriteBool(FConfigName, 'MetaDataCreated', FMetaDataCreated);
    MasterNode.Save;
    MirrorNode.Save;
  end;

  procedure DoLoadConfig;
  begin
    FMetaDataCreated := ConfigsIni.ReadBool(FConfigName, 'MetaDataCreated', False);
    FExcludedTables := ConfigsIni.ReadString(FConfigName, 'ExcludedTables', '');
    FExcludedFields := ConfigsIni.ReadString(FConfigName, 'ExcludedFields', '');
    FTrackChanges := ConfigsIni.ReadBool(FConfigName, 'TrackChanges', True);

    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    FLicence := ConfigsIni.ReadString(FConfigName, 'Licence', '');
    {$ENDIF}
    {$ENDIF}

    FSyncFrequency := StrToIntDef(ConfigsIni.ReadString(FConfigName, 'SyncFrequency', ''), 0);
    MasterDBType := ConfigsIni.ReadString(FConfigName, 'MasterDBType', '');
    MirrorDBType := ConfigsIni.ReadString(FConfigName, 'MirrorDBType', '');
  end;

begin
  cConfigDir := GetLiveMirrorRoot + 'Configs\' + FConfigName + '\';
  if not ForceDirectories(cConfigDir) then
    raise Exception.Create(Format(_('Can''t create directory "%s" '), [cConfigDir]));

  if save then
    DoSaveConfig
  else
    DoLoadConfig;
end;

function TdmConfig.DBTypeByDescription(desc: string): String;
begin
  if desc = 'Firebird' then
    Result := 'Interbase'
  else if desc =  'Microsoft SQL Server' then
    Result := 'MSSQL'
  else if desc =  'PostgreSQL' then
    Result := 'Postgres'
  else
    Result := desc;
end;

procedure TdmConfig.SetMasterDBType(const Value: String);
begin
  if FMasterDBType <> Value then begin
//    if Assigned(FMasterNode) then
//      FMasterNode.Free;

    FMasterDBType := Value;

    if FMasterDBType = '' then
      FMasterNode := nil
    else
      FMasterNode := GetNode(FMasterDBType, 'master');

    if Assigned(OnMasterDBTypeChanged) then
      OnMasterDBTypeChanged(Self);
  end;
end;

constructor TdmConfig.Create(AOwner: TComponent);
begin
  inherited;

  FMasterExcludedFields := TStringList.Create;
  FMasterExcludedFields.Sorted := True;
  FMirrorExcludedFields := TStringList.Create;
  FMirrorExcludedFields.Sorted := True;

  FRootDir := GetLiveMirrorRoot;
  ConfigsIni := TLMIniFile.Create(FRootDir + 'configs.ini');
end;

destructor TdmConfig.Destroy;
begin
  ConfigsIni.Free;
  FMirrorExcludedFields.Free;
  FMasterExcludedFields.Free;
  inherited;
end;

procedure TdmConfig.ExcludeKeywordFieldNames(FieldList: TStringList);
var
  I: Integer;
begin
  for I := FieldList.Count-1 downto 0 do begin
    if (FMirrorExcludedFields.IndexOf(FieldList[I]) > 0) or (FMasterExcludedFields.IndexOf(FieldList[I]) > 0) then begin
      FieldList.Delete(I);
    end;
  end;
end;

function TdmConfig.GetErrorConfig: TCcErrorConfigFile;
var
  cConfigPath: string;
begin
  if FErrorConfig = nil then begin
    cConfigPath := GetLiveMirrorRoot + 'Configs\' + ConfigName + '\erroroptions.ini';
    if FileExists(cConfigPath) then
      FErrorConfig := TCcErrorConfigFile.Create(cConfigPath)
    else
      FErrorConfig := TCcErrorConfigFile.Create(GetLiveMirrorRoot + '\erroroptions.ini');
  end;
  Result := FErrorConfig;
end;

function TdmConfig.GetMasterDBTypeDescription: String;
begin
  Result := DBTypeDescription(MasterDBType);
end;

function TdmConfig.GetMirrorDBTypeDescription: String;
begin
  Result := DBTypeDescription(MirrorDBType);
end;

function TdmConfig.DBTypeDescription(dbType: String): String;
begin
  if dbType = 'Interbase' then
    Result := 'Firebird'
  else if dbType =  'MSSQL' then
    Result := 'Microsoft SQL Server'
  else if dbType =  'Postgres' then
    Result := 'PostgreSQL'
  else
    Result := dbType;
end;

function TdmConfig.GetNode(dbType, nodeType: String): ILMNode;
begin
  //Assert(dbType = 'Interbase');
  if dbType = 'Interbase' then
    Result := TdmInterbase.Create(Self)
  else
    Result := TdmFireDAC.Create(Self, dbType);
  Result.Load(Self, nodeType)
end;

procedure TdmConfig.LoadConfig(cConfigName: String);
begin
  FConfigName := cConfigName;
  SaveLoadConfig(False);
end;

procedure TdmConfig.SetMirrorDBType(const Value: String);
begin
  if FMirrorDBType <> Value then begin
//    if Assigned(FMirrorNode) then
//      FMirrorNode.Free;

    FMirrorDBType := Value;

    if FMirrorDBType = '' then
      FMirrorNode := nil
    else
      FMirrorNode := GetNode(FMirrorDBType, 'mirror');

    if Assigned(OnMirrorDBTypeChanged) then
      OnMirrorDBTypeChanged(Self);

  end;
end;

procedure TdmConfig.ConfigureNodes;
begin
  ConfigureMaster;
  ConfigureMirror;
  MetaDataCreated := True;
end;

procedure TdmConfig.RemoveConfigurationFromNodes;
begin
  RemoveConfigurationFromMaster;
  RemoveConfigurationFromMirror;
  MetaDataCreated := False;
end;

procedure TdmConfig.ConfigureMaster;
var
  slTables: TStringList;
  I: Integer;
  slExcludedTables, slExcludedFields: TStringList;
  cTableName, cFieldName: String;
  tab: TCcConfigTable;
begin
  MasterConfig.TrackFieldChanges := (MasterDBType = 'Interbase') and (MasterNode.Connection.DBVersion = 'FB2.5');//TrackChanges;
  MasterConfig.Connection := FMasterNode.Connection;
  MasterConfig.Connect;
  slTables := MasterConfig.Connection.ListTables;
  MasterConfig.Tables.Clear;

  slExcludedTables := TStringList.Create;
  try
    slExcludedTables.CommaText := FExcludedTables;
    for I := 0 to slTables.Count-1 do begin
      if (Copy(Uppercase(slTables[I]), 1, 4) <> 'RPL$')
        and (slExcludedTables.IndexOf(slTables[I]) = -1) then
      begin
        MasterConfig.Tables.Add.TableName := slTables[I];
      end;
    end;
  finally
    slExcludedTables.Free;
  end;
  slExcludedFields := TStringList.Create;
  try
    slExcludedFields.CommaText := FExcludedFields;
    for I := 0 to slExcludedFields.Count-1 do begin
      cTableName := Copy(slExcludedFields[i], 1, Pos('.', slExcludedFields[i]) - 1);
      cFieldName := Copy(slExcludedFields[i], Pos('.', slExcludedFields[i]) + 1, Length(slExcludedFields[i]));
      tab := MasterConfig.Tables.FindTable(cTableName);
      if tab <> nil then
        tab.FieldsExcluded.Add(cFieldName);
    end;
  finally
    slExcludedFields.Free;
  end;
  MasterConfig.Nodes.Text := 'MIRROR';
  MasterConfig.GenerateConfig;
  MasterConfig.Disconnect;
end;

procedure TdmConfig.ConfigureMirror;
begin
  MirrorConfig.Connection := FMirrorNode.Connection;
  MirrorConfig.Connect;
  MirrorConfig.Nodes.Clear;
  MirrorConfig.Tables.Clear;
  MirrorConfig.GenerateConfig;
  MirrorConfig.Disconnect;
end;

procedure TdmConfig.RemoveConfigurationFromMirror;
begin
  MasterConfig.Connection := FMirrorNode.Connection;
  MasterConfig.ConnectAndRemoveConfig;
  MasterConfig.Disconnect;
end;

procedure TdmConfig.RemoveConfigurationFromMaster;
begin
  MasterConfig.Connection := FMasterNode.Connection;
  MasterConfig.ConnectAndRemoveConfig;
  MasterConfig.Disconnect;
end;

end.
