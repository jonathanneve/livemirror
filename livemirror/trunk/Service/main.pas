unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  CcConf, CcConfStorage, CcReplicator, CcProviders, DB;

type
  ILMNode = interface['{F9C5A7A6-C810-4C96-8D23-A35F004DB262}']
    procedure Load(configFileName: String);
    function GetConnection: TCcConnection;
    function GetDescription: String;

    property Description: String read GetDescription;
    property Connection: TCcConnection read GetConnection;
  end;

  TLiveMirror = class(TService)
    Replicator: TCcReplicator;
    MasterConfig: TCcConfig;
    MirrorConfig: TCcConfig;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ReplicatorLogLoaded(Sender: TObject);
    procedure ReplicatorRowReplicated(Sender: TObject; TableName: string;
      Fields: TFields);
    procedure ReplicatorReplicationError(Sender: TObject; e: Exception;
      var CanContinue: Boolean);
    procedure ReplicatorException(Sender: TObject; e: Exception);
    procedure ReplicatorFinished(Sender: TObject);
  private
    FConfigName: String;
    FMasterNode, FMirrorNode : ILMNode;
    function GetNode(dbType, nodeType: String): ILMNode;
    procedure ConfigDatabases;
  public
    function GetServiceController: TServiceController; override;
    { Déclarations publiques }
  end;

var
  LiveMirror: TLiveMirror;

implementation

{$R *.DFM}

uses LMUtils, IniFiles, dInterbase, Registry, HotLog, gnugettext;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  LiveMirror.Controller(CtrlCode);
end;

function TLiveMirror.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TLiveMirror.ReplicatorException(Sender: TObject; e: Exception);
begin
  LogMessage(_('Replication failed with error : ') + #13#10 + e.Message, EVENTLOG_ERROR_TYPE);
	hLog.Add('{now} ' + _('Replication failed with error : '));
	hLog.AddException(e);
end;

procedure TLiveMirror.ReplicatorFinished(Sender: TObject);
begin
//  LogMessage('Replication finished : ' + #13#10 + 'Rows replicated : ' + IntToStr(Replicator.LastResult.RowsReplicated)
//  + #13#10 + 'Rows with errors : ' + IntToStr(Replicator.LastResult.RowsErrors)
//   , EVENTLOG_INFORMATION_TYPE);
  hLog.Add(_('Replication finished : ') + #13#10 + _('Rows replicated : ') + IntToStr(Replicator.LastResult.RowsReplicated)
  + #13#10 + _('Rows with errors : ') + IntToStr(Replicator.LastResult.RowsErrors));
end;

procedure TLiveMirror.ReplicatorLogLoaded(Sender: TObject);
begin
//  LogMessage('Starting replication : ' + IntToStr(Replicator.Log.LineCount) + ' rows to replicate...', EVENTLOG_INFORMATION_TYPE);
	hLog.Add('{now} ' + _('Starting replication : ') + IntToStr(Replicator.Log.LineCount) + _(' rows to replicate...'));
end;

procedure TLiveMirror.ReplicatorReplicationError(Sender: TObject; e: Exception;
  var CanContinue: Boolean);
begin
  LogMessage(_('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.PrimaryKeys + ']' + #13#10 + e.Message, EVENTLOG_WARNING_TYPE);
	hLog.Add('{now} ' + _('Error replicating row : Table ') + Replicator.Log.TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');
	hLog.AddException(e);
end;

procedure TLiveMirror.ReplicatorRowReplicated(Sender: TObject;
  TableName: string; Fields: TFields);
begin
//  LogMessage('Row replicated : Table ' + TableName + ' [' +  Replicator.Log.PrimaryKeys + ']', EVENTLOG_INFORMATION_TYPE);
  hLog.Add('{now} ' + _('Row replicated : Table : ') + TableName + ' [' + Replicator.Log.Keys.PrimaryKeyValues + ']');
	Replicator.LocalDB.CommitRetaining;
	Replicator.RemoteDB.CommitRetaining;
end;

function TLiveMirror.GetNode(dbType, nodeType: String): ILMNode;
begin
  Assert(dbType = 'Interbase');
  if dbType = 'Interbase' then
    Result := TdmInterbase.Create(Application);
  Result.Load(GetLiveMirrorRoot + 'Configs\' + FConfigName + '\' + nodeType + '.ini');
end;

procedure TLiveMirror.ConfigDatabases;
var
  slTables: TStringList;
  I: Integer;
begin
  	hLog.Add(_('{now} Checking database configuration...'));
  LogMessage('Configuring databases for replication...', EVENTLOG_INFORMATION_TYPE);
  MasterConfig.Connection := FMasterNode.Connection;
  MasterConfig.Connect;
  slTables := MasterConfig.Connection.ListTables;
  MasterConfig.Tables.Clear;
  for I := 0 to slTables.Count-1 do begin
    if Copy(Uppercase(slTables[I]), 1, 4) <> 'RPL$' then begin
      MasterConfig.Tables.Add.TableName := slTables[I];
    end;
  end;
  MasterConfig.Nodes.Text := 'MIRROR';
  MasterConfig.GenerateConfig;
  MasterConfig.Disconnect;

  MirrorConfig.Connection := FMirrorNode.Connection;
  MirrorConfig.Connect;
  MirrorConfig.Nodes.Clear;
  MirrorConfig.Tables.Clear;
  MirrorConfig.GenerateConfig;
  MirrorConfig.Disconnect;
 	hLog.Add(_('{now} Databases configuration configured successfully!'));
end;

procedure TLiveMirror.ServiceAfterInstall(Sender: TService);
begin
  with TRegistry.Create(KEY_READ or KEY_WRITE) do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey('SYSTEM\CurrentControlSet\Services\' + Name, True) then
    begin
      WriteString('ImagePath', ReadString('ImagePath')+' ' + FConfigName);
      WriteString('Description', 'Microtec LiveMirror replication service' );
    end
  finally
    Free;
  end;
end;

procedure TLiveMirror.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  Replicator.AutoReplicate.Start;
end;

procedure TLiveMirror.ServiceCreate(Sender: TObject);
var
  slLog: TStringList;
begin
  FConfigName := ParamStr(1);
  Name := 'LiveMirror' + FConfigName;
  DisplayName := DisplayName + ' (' + FConfigName + ')';
end;

procedure TLiveMirror.ServiceExecute(Sender: TService);
var
  iniConfigs: TIniFile;
  slLog: TStringList;
  cPath: String;
  nReplFrequency: Integer;
begin
  iniConfigs := TIniFile.Create(GetLiveMirrorRoot + '\configs.ini');
  try
    nReplFrequency := StrToInt(iniConfigs.ReadString(FConfigName, 'SyncFrequency', '30'));
    FMasterNode := GetNode(iniConfigs.ReadString(FConfigName, 'MasterDBType', '') , 'master');
    FMirrorNode := GetNode(iniConfigs.ReadString(FConfigName, 'MasterDBType', ''), 'mirror');

    cPath := GetLiveMirrorRoot + 'Configs\' + FConfigName + '\log\';
    ForceDirectories(cPath);
    with hLog.hlWriter.hlFileDef do begin
      path := cPath;
      SafegdgMax := 100;
      UseSafeFilenames := true;
      UseFileSizeLimit := true;
      BuildSafeFileName;
      LogFileMaxSize := OneMegabyte;
    end;
    hlog.SetLogFileTimerInterval(OneMinute);
    hLog.StartLogging;
    hLog.Add('{/}{LNumOff}{*80*}');
    hLog.Add(_('>>>> Start {App_name}') + ' v ' + LiveMirrorVersion + '{80@}{&}{dte} {hms}{&}');
    hLog.Add(_('{@12}Path : {App_path}'));
    hLog.Add(_('{@12}Config. name : {App_prm-}{/}'));
  	hLog.Add(_('MASTER database :') + #9 + FMasterNode.Description);
  	hLog.Add(_('MIRROR database :') + #9 + FMirrorNode.Description);
	  hLog.Add(_('Replication frequency :') + #9 + IntToStr(nReplFrequency) + _(' seconds'));
    hLog.Add('{/}{LNumOff}{*80*}');

    //Create replication meta-data and triggers if they aren't there
    //Any new tables are automatically detected and triggers added
    ConfigDatabases;

    Replicator.AutoReplicate.Frequency := nReplFrequency;
    Replicator.AutoReplicate.Enabled := True;
    Replicator.LocalNode.Connection := FMasterNode.Connection;
    Replicator.LocalNode.Name := 'MASTER';
    Replicator.RemoteNode.Connection := FMirrorNode.Connection;
    Replicator.RemoteNode.Name := 'MIRROR';
    Replicator.AutoReplicate.Start;
  	hLog.Add(_('{now} Service ready!'));
  finally
    iniConfigs.Free;
  end;

  while not Terminated do begin
    ServiceThread.ProcessRequests(true);
  end;
end;

procedure TLiveMirror.ServicePause(Sender: TService; var Paused: Boolean);
begin
  Replicator.AutoReplicate.Stop;
  Replicator.AbortReplication;
end;

procedure TLiveMirror.ServiceShutdown(Sender: TService);
begin
  Replicator.AutoReplicate.Stop;
  Replicator.AbortReplication;
end;

procedure TLiveMirror.ServiceStart(Sender: TService; var Started: Boolean);
var
  slLog: TStringList;
begin
  Replicator.AutoReplicate.Start;
end;

procedure TLiveMirror.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Replicator.AutoReplicate.Stop;
  Replicator.AbortReplication;
end;

end.
