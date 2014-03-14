unit configs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfmConfigs = class(TForm)
    GroupBox1: TGroupBox;
    listConfigs: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure listConfigsDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    cConfigFileName: String;
    procedure LoadConfigs;
    procedure Init;
    procedure DeleteConfig(cConfigName: String);
    procedure DeleteDirectory(const DirName: string);
    procedure UnInstallService(cConfigName: String);
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  fmConfigs: TfmConfigs;

implementation

{$R *.dfm}

uses IniFiles, gnugettext, config, Registry, LMUtils, ServiceManager, ShellApi;

procedure TfmConfigs.Init;
begin
  cConfigFileName := GetLiveMirrorRoot + '\configs.ini';
  LoadConfigs;
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
  if not FileExists(cConfigFileName) then
    TfmConfig.NewConfig;
  ini := TIniFile.Create(cConfigFileName);
  try
    ini.ReadSections(listConfigs.Items);
  finally
    ini.Free;
  end;
end;

procedure TfmConfigs.Button1Click(Sender: TObject);
begin
  TfmConfig.NewConfig;
  LoadConfigs;
end;

procedure TfmConfigs.Button2Click(Sender: TObject);
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

procedure TfmConfigs.Button3Click(Sender: TObject);
begin
  if listConfigs.ItemIndex <> -1 then begin
    TfmConfig.EditConfig(listConfigs.Items[listConfigs.ItemIndex]);
    LoadConfigs;
  end;
end;
                    
procedure TfmConfigs.Button4Click(Sender: TObject);
var
  srvMgr: TServiceManager;
  cConfigName: String;
begin
  if listConfigs.ItemIndex <> -1 then begin
    cConfigName := listConfigs.Items[listConfigs.ItemIndex];
    srvMgr := TServiceManager.Create;
    try
      srvMgr.ServiceByName['LiveMirror' + cConfigName].ServiceStart(true);
    finally
      srvMgr.Free;
    end;
  end;
end;

procedure TfmConfigs.Button6Click(Sender: TObject);
begin
  ShellExecute(handle,'open',PChar('c:\projects\livemirror\Service\livemirrorsvr.exe'), PChar('Test /install'),'',SW_HIDE);
end;

procedure TfmConfigs.FormCreate(Sender: TObject);
begin
  TranslateComponent (self);
  Init;
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
