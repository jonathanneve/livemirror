unit config;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, Data.DB,
  FireDAC.Comp.Client, Vcl.StdCtrls, Vcl.ExtCtrls, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors,
  Data.Bind.Components, Vcl.ComCtrls, FireDAC.Phys.FB, FireDAC.Phys.IBBase,
  FireDAC.Phys.IB, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL;

type
  ILMConnectionFrame = interface['{E67ED917-1575-4159-B547-35CCD40881A9}']
    procedure Init(parentCtrl: TWinControl);
    procedure Load(configFileName: String);
    procedure Save(configFileName: String);
    procedure SetName(cName: String);
    function GetDBType: String;

    property DBType: String read GetDBType;
  end;

  TfmConfig = class(TForm)
    edConfigName: TLabeledEdit;
    edFrenquency: TLabeledEdit;
    PageControl1: TPageControl;
    tsMaster: TTabSheet;
    tsMirror: TTabSheet;
    Button3: TButton;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    lNewConfig: Boolean;
    FMasterFrame, FMirrorFrame: ILMConnectionFrame;
    procedure LoadConfig(cConfigName: String);
    procedure SaveConfig;
    procedure SaveLoadConfig(cConfigName: String; save: Boolean);
    function CreateConnectionFrame(dbType: String;
      ts: TTabSheet; frameName: String): ILMConnectionFrame;
    procedure CreateConnectionFrames(dbTypeMaster, dbTypeMirror: String);
    { Déclarations privées }
    procedure InstallService;
  public
    class procedure NewConfig;
    class procedure EditConfig(cConfigName: String);
  end;


implementation

{$R *.dfm}

uses FireDAC.VCLUI.ConnEdit, gnugettext, Inifiles, fConnectParamsFB, LMUtils, ShellAPI;

procedure TfmConfig.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if lNewConfig and (ModalResult = mrOk) then
    InstallService;
end;

procedure TfmConfig.FormCreate(Sender: TObject);
begin
  TranslateComponent(self);
end;

function TfmConfig.CreateConnectionFrame(dbType: String; ts: TTabSheet; frameName: String): ILMConnectionFrame;
begin
  if dbType = 'Interbase' then
    Result := TfrConnectParamsFB.Create(Self);
  Result.Init(ts);
  Result.SetName(frameName);
end;

procedure TfmConfig.SaveLoadConfig(cConfigName: String; save: Boolean);
var
  cRootDir, cConfigDir : String;
  ConfigsIni, MasterIni, MirrorIni: TIniFile;

  procedure DoSaveConfig;
  begin
    ConfigsIni.WriteString(cConfigName, 'SyncFrequency', edFrenquency.Text);
    ConfigsIni.WriteString(cConfigName, 'MasterDBType', FMasterFrame.DBType);
    ConfigsIni.WriteString(cConfigName, 'MirrorDBType', FMirrorFrame.DBType);
    FMasterFrame.Save(cConfigDir + 'master.ini');
    FMirrorFrame.Save(cConfigDir + 'mirror.ini');
  end;

  procedure DoLoadConfig;
  begin
    edConfigName.Enabled := False;
    edConfigName.Text := cConfigName;
    edFrenquency.Text := ConfigsIni.ReadString(cConfigName, 'SyncFrequency', '');
    FMasterFrame := CreateConnectionFrame(ConfigsIni.ReadString(cConfigName, 'MasterDBType', ''), tsMaster, '_Master');
    FMasterFrame.Load(cConfigDir + 'master.ini');
    FMirrorFrame := CreateConnectionFrame(ConfigsIni.ReadString(cConfigName, 'MirrorDBType', ''), tsMirror, '_Mirror');
    FMirrorFrame.Load(cConfigDir + 'mirror.ini');
  end;

begin
  cRootDir := GetLiveMirrorRoot + '\';
  cConfigDir := cRootDir + cConfigName + '\';
  if not ForceDirectories(cConfigDir) then
    raise Exception.Create(Format(_('Can''t create directory "%s" '), [cConfigDir]));

  ConfigsIni := TIniFile.Create(cRootDir + 'configs.ini');
  try
    if save then
      DoSaveConfig
    else
      DoLoadConfig;
  finally
    ConfigsIni.Free;
  end;
end;

procedure TfmConfig.SaveConfig;
begin
  SaveLoadConfig(Trim(edConfigName.Text), true);
end;

procedure TfmConfig.LoadConfig(cConfigName: String);
begin
  SaveLoadConfig(cConfigName, false);
end;

procedure TfmConfig.CreateConnectionFrames(dbTypeMaster, dbTypeMirror: String);
begin
  FMasterFrame := CreateConnectionFrame(dbTypeMaster, tsMaster, '_Master');
  FMirrorFrame := CreateConnectionFrame(dbTypeMirror, tsMirror, '_Mirror');
end;

class procedure TfmConfig.NewConfig;
var
  fmConfig : TfmConfig;
begin
  fmConfig := TfmConfig.Create(Application);
  fmConfig.lNewConfig := True;
  fmConfig.CreateConnectionFrames('Interbase', 'Interbase');
  try
    if fmConfig.ShowModal = mrOk then begin
      fmConfig.SaveConfig;
    end;
  finally
    fmConfig.Free;
  end;
end;

class procedure TfmConfig.EditConfig(cConfigName: String);
var
  fmConfig : TfmConfig;
begin
  fmConfig := TfmConfig.Create(Application);
  try
    fmConfig.LoadConfig(cConfigName);
    if fmConfig.ShowModal = mrOk then
      fmConfig.SaveConfig;
  finally
    fmConfig.Free;
  end;
end;

procedure TfmConfig.InstallService;
var
  cConfigName: String;
begin
  cConfigName := Trim(edConfigName.Text);
  if ShellExecute(Handle,'open',PChar(GetLiveMirrorRoot + '\Service\LiveMirrorSrv.exe'), PChar(cConfigName + ' /install /silent'),'',SW_HIDE) <= 32 then
    raise Exception.Create(_('Can''t install service!'));
end;

end.
