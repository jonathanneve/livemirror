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
  FireDAC.Phys.IB, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, Vcl.Mask;

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
    edFrenquency: TLabeledEdit;
    PageControl1: TPageControl;
    tsMaster: TTabSheet;
    tsMirror: TTabSheet;
    Button3: TButton;
    Button4: TButton;
    edConfigName: TMaskEdit;
    Label1: TLabel;
    btLicensing: TButton;
    lbEvaluation: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btLicensingClick(Sender: TObject);
  private
    lNewConfig: Boolean;
    FLicence: String;
    FMasterFrame, FMirrorFrame: ILMConnectionFrame;
    procedure LoadConfig(cConfigName: String);
    procedure SaveConfig;
    procedure SaveLoadConfig(cConfigName: String; save: Boolean);
    function CreateConnectionFrame(dbType: String;
      ts: TTabSheet; frameName: String): ILMConnectionFrame;
    procedure CreateConnectionFrames(dbTypeMaster, dbTypeMirror: String);
    { Déclarations privées }
    procedure ServiceInstall;
  public
    class function NewConfig: Boolean;
    class procedure EditConfig(cConfigName: String);
  end;


implementation

{$R *.dfm}

uses FireDAC.VCLUI.ConnEdit, gnugettext, Inifiles, fConnectParamsFB, LMUtils, ShellAPI,
  licensing;

procedure TfmConfig.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult = mrOk then begin
    if Trim(edConfigName.Text) = '' then begin
      Application.MessageBox(PChar(_('You must enter a name for this configuration!')), PChar(_('Configuration name missing')), MB_ICONERROR + MB_OK);
      CanClose := False;
      Exit;
    end;

    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    if FLicence = '' then
      FLicence := TfmLicensing.AskForLicence(Trim(edConfigName.Text));
    if FLicence = '' then begin
      CanClose := False;
      Exit;
    end;
    {$ENDIF}
    {$ENDIF}

    if lNewConfig then
      ServiceInstall;
  end;
end;

procedure TfmConfig.FormCreate(Sender: TObject);
begin
  TranslateComponent(self);
  {$IFDEF LM_EVALUATION}
  lbEvaluation.Visible := True;
  btLicensing.Visible := False;
  {$ELSE}
  lbEvaluation.Visible := False;
  btLicensing.Visible := True;
  {$ENDIF}
end;

procedure TfmConfig.btLicensingClick(Sender: TObject);
begin
  FLicence := TfmLicensing.AskForLicence(Trim(edConfigName.Text));
end;

function TfmConfig.CreateConnectionFrame(dbType: String; ts: TTabSheet; frameName: String): ILMConnectionFrame;
begin
  if dbType = 'Interbase' then
    Result := TfrConnectParamsFB.Create(Application);
  Result.Init(ts);
  Result.SetName(frameName);
end;

procedure TfmConfig.SaveLoadConfig(cConfigName: String; save: Boolean);
var
  cRootDir, cConfigDir : String;
  ConfigsIni: TIniFile;

  procedure DoSaveConfig;
  begin
    ConfigsIni.WriteString(cConfigName, 'SyncFrequency', edFrenquency.Text);
    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    ConfigsIni.WriteString(cConfigName, 'Licence', FLicence);
    {$ENDIF}
    {$ENDIF}
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
  cRootDir := GetLiveMirrorRoot;
  cConfigDir := cRootDir + 'Configs\' + cConfigName + '\';
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

procedure TfmConfig.ServiceInstall;
begin
  InstallService(Trim(edConfigName.Text), Handle);
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

class function TfmConfig.NewConfig: Boolean;
var
  fmConfig : TfmConfig;
begin
  fmConfig := TfmConfig.Create(Application);
  fmConfig.lNewConfig := True;
  fmConfig.CreateConnectionFrames('Interbase', 'Interbase');
  try
    if fmConfig.ShowModal = mrOk then begin
      fmConfig.SaveConfig;
      Result := True;
    end
    else
      Result := False;
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

end.
