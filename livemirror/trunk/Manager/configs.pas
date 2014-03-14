unit configs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Pipes, ServiceManager,
  Vcl.ExtCtrls, Vcl.Buttons;

type
  TfmConfigs = class(TForm)
    GroupBox: TGroupBox;
    listConfigs: TListBox;
    btAdd: TBitBtn;
    btDelete: TBitBtn;
    btProperties: TBitBtn;
    PipeServer: TPipeServer;
    PipeClient: TPipeClient;
    Label1: TLabel;
    lbServiceStatus: TLabel;
    btServiceStopStart: TButton;
    ServiceRefreshTimer: TTimer;
    Label2: TLabel;
    lbVersion: TLabel;
    procedure btAddClick(Sender: TObject);
    procedure btPropertiesClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure listConfigsDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btServiceStopStartClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure PipeServerPipeConnect(Sender: TObject; Pipe: HPIPE);
    procedure FormDestroy(Sender: TObject);
    procedure ServiceRefreshTimerTimer(Sender: TObject);
  private
    cConfigFileName: String;
    srvMgr: TServiceManager;
    procedure LoadConfigs;
    procedure Init;
    procedure DeleteConfig(cConfigName: String);
    procedure DeleteDirectory(const DirName: string);
    procedure UnInstallService(cConfigName: String);
    procedure RefreshServiceStatus;
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  fmConfigs: TfmConfigs;

implementation

{$R *.dfm}

uses IniFiles, gnugettext, config, Registry, LMUtils, ShellApi;

procedure TfmConfigs.Init;
begin
//  if PipeClient.Connect(50) then
//    Application.Terminate
//  else begin
//   PipeServer.Active := True;

    cConfigFileName := GetLiveMirrorRoot + 'configs.ini';
    LoadConfigs;
    lbVersion.Caption := LiveMirrorVersion;
    ServiceRefreshTimer.Enabled := True;
  //end;
end;

procedure TfmConfigs.listConfigsDblClick(Sender: TObject);
begin
  if listConfigs.ItemIndex <> -1 then begin
    TfmConfig.EditConfig(listConfigs.Items[listConfigs.ItemIndex]);
    LoadConfigs;
  end;
end;

procedure TfmConfigs.LoadConfigs;
var
  ini:TIniFile;
begin
//  if not FileExists(cConfigFileName) then
//    TfmConfig.NewConfig;
  ini := TIniFile.Create(cConfigFileName);
  try
    ini.ReadSections(listConfigs.Items);
  finally
    ini.Free;
  end;
  if listConfigs.Items.Count = 0 then begin
    if TfmConfig.NewConfig then
      LoadConfigs
    else
      Application.Terminate;
  end;
end;

procedure TfmConfigs.PipeServerPipeConnect(Sender: TObject; Pipe: HPIPE);
begin
//  Application.BringToFront;
end;

procedure TfmConfigs.btAddClick(Sender: TObject);
begin
  TfmConfig.NewConfig;
  LoadConfigs;
end;

procedure TfmConfigs.btDeleteClick(Sender: TObject);
var
  cConfigName: String;
begin
  if listConfigs.ItemIndex <> -1 then begin
    if Application.MessageBox(PWideChar(_('Are you sure you want to delete this backup configuration?')), PWideChar(_('Delete confirmation')), MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2) = IDYES then begin
      cConfigName := listConfigs.Items[listConfigs.ItemIndex];
      UnInstallService(cConfigName);
      DeleteDirectory(ExtractFileDir(cConfigFileName) + '\' + cConfigName);
      DeleteConfig(cConfigName);
    end;
  end;
end;

procedure TfmConfigs.DeleteDirectory(const DirName: string);
var
  F: TSearchRec;
begin
  if FindFirst(DirName + '\*', faAnyFile, F) = 0 then begin
    try
      repeat
        if (F.Attr and faDirectory <> 0) then begin
          if (F.Name <> '.') and (F.Name <> '..') then begin
            DeleteDirectory(DirName + '\' + F.Name);
          end;
        end else begin
          DeleteFile(DirName + '\' + F.Name);
        end;
      until FindNext(F) <> 0;
      RemoveDir(DirName);
    finally
      FindClose(F);
    end;
  end;
end;

procedure TfmConfigs.btPropertiesClick(Sender: TObject);
begin
  if listConfigs.ItemIndex <> -1 then begin
    TfmConfig.EditConfig(listConfigs.Items[listConfigs.ItemIndex]);
    LoadConfigs;
  end;
end;
                    
procedure TfmConfigs.btServiceStopStartClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    if btServiceStopStart.Tag = 1 then
      //Service running
      srvMgr.ServiceByName['LiveMirror'].ServiceStop(True)
    else
      srvMgr.ServiceByName['LiveMirror'].ServiceStart(True);
    RefreshServiceStatus;
  finally
    Screen.Cursor := crDefault;
  end;

{  if listConfigs.ItemIndex <> -1 then begin
    cConfigName := listConfigs.Items[listConfigs.ItemIndex];
    srvMgr.ServiceByName['LiveMirror' + cConfigName].ServiceStart(true);
  end; }
end;

procedure TfmConfigs.Button6Click(Sender: TObject);
begin
  ShellExecute(handle,'open',PChar('c:\projects\livemirror\Service\livemirrorsvr.exe'), PChar('Test /install'),'',SW_HIDE);
end;

procedure TfmConfigs.FormCreate(Sender: TObject);
begin
  TranslateComponent (self);
  srvMgr := TServiceManager.Create;
  srvMgr.Active := True;

  Init;
  RefreshServiceStatus;
end;

procedure TfmConfigs.RefreshServiceStatus;
var
  srv: TServiceInfo;
begin
  srv :=  srvMgr.ServiceByName['LiveMirror'];
  if not Assigned(srv) or (srvMgr.ServiceByName['LiveMirror'].State = ssRunning) then begin
    if not Assigned(srv)  then begin
      lbServiceStatus.Caption := _('UNINSTALLED');
      lbServiceStatus.Font.Color := clBlack;
      btServiceStopStart.Enabled := False;
    end else begin
      lbServiceStatus.Caption := _('RUNNING');
      lbServiceStatus.Font.Color := clGreen;
      btServiceStopStart.Caption := _('Stop');
    end;
    btServiceStopStart.Tag := 1;
    listConfigs.Enabled := False;
    btAdd.Enabled := False;
    btProperties.Enabled := False;
    btDelete.Enabled := False;
  end else begin
    lbServiceStatus.Caption := _('STOPPED');
    lbServiceStatus.Font.Color := clRed;
    btServiceStopStart.Caption := _('Start');
    btServiceStopStart.Tag := 0;
    listConfigs.Enabled := True;
    btAdd.Enabled := True;
    btProperties.Enabled := True;
    btDelete.Enabled := True;
  end;
end;

procedure TfmConfigs.ServiceRefreshTimerTimer(Sender: TObject);
begin
  RefreshServiceStatus;
end;

procedure TfmConfigs.FormDestroy(Sender: TObject);
begin
  srvMgr.Free;
end;

procedure TfmConfigs.DeleteConfig(cConfigName: String);
var
  ini:TIniFile;
begin
  ini := TIniFile.Create(cConfigFileName);
  try
    ini.EraseSection(cConfigName);
  finally
    ini.Free;
  end;
  LoadConfigs;
end;

procedure TfmConfigs.UnInstallService(cConfigName: String);
begin
  if ShellExecute(Handle,'open',PChar(GetLiveMirrorRoot + '\Service\LiveMirrorSrv.exe'), PChar(cConfigName + ' /uninstall /silent'),'',SW_HIDE) < 32 then
    raise Exception.Create(_('Can''t uninstall service!'));
end;

end.
