unit configs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ServiceManager,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.Grids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Moni.Base, FireDAC.Moni.FlatFile;

type
  TfmConfigs = class(TForm)
    ServiceRefreshTimer: TTimer;
    Panel1: TPanel;
    GroupBox: TGroupBox;
    listConfigs: TListBox;
    btAdd: TBitBtn;
    btDelete: TBitBtn;
    btProperties: TBitBtn;
    Panel3: TPanel;
    Label1: TLabel;
    lbServiceStatus: TLabel;
    Label2: TLabel;
    lbVersion: TLabel;
    btServiceStopStart: TButton;
    pnEvaluation: TPanel;
    lbEvaluation: TLabel;
    btLog: TBitBtn;
    procedure btAddClick(Sender: TObject);
    procedure btPropertiesClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure listConfigsDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btServiceStopStartClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ServiceRefreshTimerTimer(Sender: TObject);
    procedure btLogClick(Sender: TObject);
  private
    lServiceRunning: Boolean;
    slConfigLicences: TStringList;
    cConfigFileName: String;
    srvMgr: TServiceManager;
    procedure LoadConfigs;
    procedure Init;
    procedure DeleteConfig(cConfigName: String);
    procedure DeleteDirectory(const DirName: string);
    procedure RefreshServiceStatus;
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  fmConfigs: TfmConfigs;

implementation

{$R *.dfm}

uses IniFiles, gnugettext, config, Registry, LMUtils, ShellApi, logfile;

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
  if not lServiceRunning then begin
    if listConfigs.ItemIndex <> -1 then begin
      TfmConfig.EditConfig(listConfigs.Items[listConfigs.ItemIndex]);
      LoadConfigs;
    end;
  end;
end;

procedure TfmConfigs.LoadConfigs;
var
  ini:TIniFile;
  I: Integer;
begin
//  if not FileExists(cConfigFileName) then
//    TfmConfig.NewConfig;
  ini := TIniFile.Create(cConfigFileName);
  try
    ini.ReadSections(listConfigs.Items);

    {$IFNDEF LM_EVALUATION}
    slConfigLicences.Clear;
    for I := 0 to listConfigs.Items.Count-1 do
      slConfigLicences.Values[listConfigs.Items[I]] := ini.ReadString(listConfigs.Items[I], 'Licence', '');
    {$ENDIF}
  finally
    ini.Free;
  end;

  listConfigs.ItemIndex := 0;

  if listConfigs.Items.Count = 0 then begin
    if TfmConfig.NewConfig then
      LoadConfigs
    else
      Application.Terminate;
  end;
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
      {$IFNDEF LM_EVALUATION}
      DeactivateLicence(cConfigName, slConfigLicences.Values[cConfigName]);
      {$ENDIF}

      UnInstallService(cConfigName, Handle);
      DeleteDirectory(ExtractFileDir(cConfigFileName) + '\' + cConfigName);
      DeleteConfig(cConfigName);
    end;
  end;
end;

function GetLastModifiedFileName(AFolder: String; APattern: String = '*.*'): String;
var
  sr: TSearchRec;
  aTime: Integer;
begin
  Result := '';
  aTime := 0;
  if FindFirst(IncludeTrailingPathDelimiter(AFolder) + APattern, faAnyFile, sr) = 0 then
  begin
    repeat
      if sr.Time > aTime then
      begin
        aTime := sr.Time;
        Result := sr.Name;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;

procedure TfmConfigs.btLogClick(Sender: TObject);
var
  cConfigName, cLogDir, cLastLogFile : String;
begin
  if listConfigs.ItemIndex <> -1 then begin
    cConfigName := listConfigs.Items[listConfigs.ItemIndex];
    cLogDir := GetLiveMirrorRoot + '\Configs\' + cConfigName + '\log\';
    cLastLogFile := GetLastModifiedFileName(cLogDir, '*.log');
    if cLastLogFile = '' then
      Application.MessageBox(PWideChar(_('No log file is available yet for this configuration.'+#13#10+'A log file will be created automatically when the service is first run.')), PWideChar(_('No log file found')), MB_ICONINFORMATION + MB_OK)
    else begin
      TfmLogFile.ShowLogFile(cLogDir + '\' + cLastLogFile);
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
    else begin
      {$IFDEF LM_EVALUATION}
      Application.MessageBox('You are using CopyCat LiveMirror evaluation version.'#13#10'The database synchronization service will stop after 1 hour of use.'#13#10'Please purchase registered version to remove this limitation',
        'Evaluation version', MB_ICONINFORMATION + MB_OK);
      {$ENDIF}
      srvMgr.ServiceByName['LiveMirror'].ServiceStart(True);
    end;
    RefreshServiceStatus;
  finally
    Screen.Cursor := crDefault;
  end;

{  if listConfigs.ItemIndex <> -1 then begin
    cConfigName := listConfigs.Items[listConfigs.ItemIndex];
    srvMgr.ServiceByName['LiveMirror' + cConfigName].ServiceStart(true);
  end; }
end;

procedure TfmConfigs.FormCreate(Sender: TObject);
var
  ResultMessage:String;
begin
  TranslateComponent (self);
  slConfigLicences := TStringList.Create;
  srvMgr := TServiceManager.Create;
  srvMgr.Active := True;

  Init;
  RefreshServiceStatus;

  {$IFDEF LM_EVALUATION}
  pnEvaluation.Visible := True;
  {$ELSE}
  pnEvaluation.Visible := False;
  {$ENDIF}
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
    lServiceRunning := True;
    btServiceStopStart.Tag := 1;
    //listConfigs.Enabled := False;
    btAdd.Enabled := False;
    btProperties.Enabled := False;
    btDelete.Enabled := False;
  end else begin
    lServiceRunning := False;
    lbServiceStatus.Caption := _('STOPPED');
    lbServiceStatus.Font.Color := clRed;
    btServiceStopStart.Caption := _('Start');
    btServiceStopStart.Tag := 0;
   // listConfigs.Enabled := True;
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
  slConfigLicences.Free;
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

end.
