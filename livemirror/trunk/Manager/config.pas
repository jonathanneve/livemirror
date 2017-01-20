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
  FireDAC.Phys.IB, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, Vcl.Mask, IniFiles, CcProviders,
  CcConf, dconfig, erroroptions;

type
(*  ILMConnectionFrame = interface['{E67ED917-1575-4159-B547-35CCD40881A9}']
    procedure Init(parentCtrl: TWinControl);
    procedure Load(configFileName: String);
    procedure Save(configFileName: String);
    procedure SetName(cName: String);
    function GetDBType: String;
    function GetConnection: TCcConnection;

    property Connection : TCcConnection read GetConnection;
    property DBType: String read GetDBType;
  end; *)

  TfmConfig = class(TForm)
    edFrenquency: TLabeledEdit;
    PageControl: TPageControl;
    tsMaster: TTabSheet;
    tsMirror: TTabSheet;
    Button3: TButton;
    Button4: TButton;
    edConfigName: TMaskEdit;
    Label1: TLabel;
    btLicensing: TButton;
    CcConfig: TCcConfig;
    Options: TTabSheet;
    rbAllTables: TRadioButton;
    rbExcludeSelectedTables: TRadioButton;
    lbSelectExcludedTables: TLabel;
    lbMetaDataStatus: TLabel;
    lbAddRemoveMetaData: TLabel;
    cbTrackChanges: TCheckBox;
    Panel1: TPanel;
    cbMasterDBType: TComboBox;
    Label2: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    cbMirrorDBType: TComboBox;
    TabSheet1: TTabSheet;
    cbDefaultErrorReporting: TRadioButton;
    cbCustomErrorManagement: TRadioButton;
    btErrorConfig: TButton;
    lbExcludedFields: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btLicensingClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbSelectExcludedTablesClick(Sender: TObject);
    procedure lbAddRemoveMetaDataClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edConfigNameChange(Sender: TObject);
    procedure edFrenquencyChange(Sender: TObject);
    procedure rbAllTablesClick(Sender: TObject);
    procedure cbTrackChangesClick(Sender: TObject);
    procedure cbMasterDBTypeChange(Sender: TObject);
    procedure cbMirrorDBTypeChange(Sender: TObject);
    procedure cbDefaultErrorReportingClick(Sender: TObject);
    procedure btErrorConfigClick(Sender: TObject);
    procedure cbCustomErrorManagementClick(Sender: TObject);
    procedure lbExcludedFieldsClick(Sender: TObject);
  private
    ConfigsIni: TIniFile;
    lNewConfig: Boolean;
    FRootDir: String;
    FMasterFrame, FMirrorFrame: ILMConnectionFrame;
    FdmConfig: TdmConfig;

    function CreateConnectionFrame(node: ILMNode;
      ts: TTabSheet): ILMConnectionFrame;
    { Déclarations privées }
    procedure RefreshGUI;
    procedure MasterDBTypeChanged(Sender: TObject);
    procedure MirrorDBTypeChanged(Sender: TObject);
    class function DoEditConfig(cConfigName: String): String; static;
    procedure SaveConfig;
    function GetErrorOptionsPath: String;
//    procedure LoadConfig(cConfigName: String);
  public
    property dmConfig: TdmConfig read FdmConfig;
    procedure RemoveCopyCatConfig(cConfigName: String);
    class function NewConfig: String;
    class function EditConfig(cConfigName: String): Boolean;
  end;


implementation

{$R *.dfm}

uses FireDAC.VCLUI.ConnEdit, gnugettext, fConnectParamsFB, LMUtils, ShellAPI,
  licensing, configoptions, fConnectParamsFireDAC, configfields;

procedure TfmConfig.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult = mrOk then begin
    if Trim(dmConfig.ConfigName) = '' then begin
      Application.MessageBox(PChar(_('You must enter a name for this configuration!')), PChar(_('Configuration name missing')), MB_ICONERROR + MB_OK);
      CanClose := False;
      Exit;
    end;

    {$IFNDEF LM_EVALUATION}
    {$IFNDEF DEBUG}
    if dmConfig.Licence = '' then
      dmConfig.Licence := TfmLicensing.AskForLicence(Trim(dmConfig.ConfigName));
    if dmConfig.Licence = '' then begin
      CanClose := False;
      Exit;
    end;
    {$ENDIF}
    {$ENDIF}

{    if lNewConfig then
      ServiceInstall;}
  end;
end;

procedure TfmConfig.FormCreate(Sender: TObject);
begin
  TranslateComponent(self);
  btLicensing.Visible := True;

  FRootDir := GetLiveMirrorRoot;
  ConfigsIni := TIniFile.Create(FRootDir + 'configs.ini');

  FdmConfig := TdmConfig.Create(Self);
  FdmConfig.OnMasterDBTypeChanged := MasterDBTypeChanged;
  FdmConfig.OnMirrorDBTypeChanged := MirrorDBTypeChanged;
end;

procedure TfmConfig.MirrorDBTypeChanged(Sender: TObject);
begin
  if FMirrorFrame <> nil then
    FMirrorFrame.FreeFrame;
  FMirrorFrame := CreateConnectionFrame(FdmConfig.MirrorNode, tsMirror);
end;

procedure TfmConfig.MasterDBTypeChanged(Sender: TObject);
begin
  if FMasterFrame <> nil then
    FMasterFrame.FreeFrame;
  FMasterFrame := CreateConnectionFrame(FdmConfig.MasterNode, tsMaster);
end;

procedure TfmConfig.FormDestroy(Sender: TObject);
begin
  ConfigsIni.Free;
  FdmConfig.Free;
end;

procedure TfmConfig.FormShow(Sender: TObject);
begin
{  if lNewConfig then begin
    //For now, we hard-code to Interbase/Firebird frames
    //Eventually, we will give the end user a choice
    FdmConfig.MasterDBType := 'Interbase';
    FdmConfig.MirrorDBType := 'Interbase';
  end;}
  RefreshGUI;
  PageControl.ActivePage := tsMaster;
end;

procedure TfmConfig.lbAddRemoveMetaDataClick(Sender: TObject);
begin
  if dmConfig.MetaDataCreated then
    dmConfig.RemoveConfigurationFromNodes
  else
    dmConfig.ConfigureNodes;
  RefreshGUI;
end;

procedure TfmConfig.lbExcludedFieldsClick(Sender: TObject);
begin
  TfmConfigFields.Display(Self, dmConfig);
end;

procedure TfmConfig.lbSelectExcludedTablesClick(Sender: TObject);
var
  confOptions :TfmConfigOptions;
begin
  confOptions := TfmConfigOptions.Create(Self);
  try
    confOptions.ShowOptions(dmConfig);
    RefreshGUI;
  finally
    confOptions.Free;
  end;
end;

procedure TfmConfig.btLicensingClick(Sender: TObject);
begin
  dmConfig.Licence := TfmLicensing.AskForLicence(Trim(dmConfig.ConfigName));
end;

procedure TfmConfig.btErrorConfigClick(Sender: TObject);
var
  fmErrorOptions: TfmErrorOptions;
begin
  fmErrorOptions := TfmErrorOptions.Create(Self);
  fmErrorOptions.Init(GetErrorOptionsPath);
  fmErrorOptions.ShowModal;
  fmErrorOptions.Free;
end;

procedure TfmConfig.cbDefaultErrorReportingClick(Sender: TObject);
begin
  if cbDefaultErrorReporting.Checked then begin
    if FileExists(GetErrorOptionsPath) then
      DeleteFile(GetErrorOptionsPath);
    btErrorConfig.Enabled := False;
  end;
end;

procedure TfmConfig.cbMasterDBTypeChange(Sender: TObject);
begin
  dmConfig.MasterDBType := dmConfig.DBTypeByDescription(cbMasterDBType.Text);
end;

procedure TfmConfig.cbMirrorDBTypeChange(Sender: TObject);
begin
  dmConfig.MirrorDBType := dmConfig.DBTypeByDescription(cbMirrorDBType.Text);
end;

procedure TfmConfig.cbTrackChangesClick(Sender: TObject);
begin
  dmConfig.TrackChanges := cbTrackChanges.Checked;
end;

function TfmConfig.CreateConnectionFrame(node: ILMNode; ts: TTabSheet): ILMConnectionFrame;
begin
  if node.Connection.DBType = 'Interbase' then
    Result := TfrConnectParamsFB.Create(Self)
  else
    Result := TfrConnectParamsFireDAC.Create(Self);

  Result.Node := node;
  Result.Init(ts);
end;

procedure TfmConfig.SaveConfig;
begin
  if FMasterFrame <> nil then
    FMasterFrame.SaveToNode;
  if FMirrorFrame <> nil then
    FMirrorFrame.SaveToNode;
  dmConfig.SaveConfig;
end;

class function TfmConfig.DoEditConfig(cConfigName: String): String;
var
  fmConfig : TfmConfig;
begin
  fmConfig := TfmConfig.Create(Application);
  try
    if cConfigName = '' then
      fmConfig.lNewConfig := True
    else
      fmConfig.dmConfig.LoadConfig(cConfigName);

    if fmConfig.ShowModal = mrOk then begin
      fmConfig.SaveConfig;
      Result := fmConfig.dmConfig.ConfigName;
    end
    else
      Result := '';
  finally
    fmConfig.Free;
  end;
end;

procedure TfmConfig.edConfigNameChange(Sender: TObject);
begin
  dmConfig.ConfigName := edConfigName.Text;
end;

procedure TfmConfig.edFrenquencyChange(Sender: TObject);
begin
  dmConfig.SyncFrequency := StrToInt(edFrenquency.Text);
end;

class function TfmConfig.NewConfig: String;
begin
  Result := DoEditConfig('');
end;

procedure TfmConfig.cbCustomErrorManagementClick(Sender: TObject);
begin
  btErrorConfig.Enabled := True;
end;

function TfmConfig.GetErrorOptionsPath: String;
begin
  Result := GetLiveMirrorRoot + 'Configs\' + dmConfig.ConfigName + '\erroroptions.ini'
end;

procedure TfmConfig.rbAllTablesClick(Sender: TObject);
begin
  if rbAllTables.Checked then
    dmConfig.ExcludedTables := '';
end;

class function TfmConfig.EditConfig(cConfigName: String): Boolean;
begin
  Result := DoEditConfig(cConfigName) <> '';
end;

procedure TfmConfig.RemoveCopyCatConfig(cConfigName: String);
//var
//  dmMetaData: TdmMetaData;
begin
{  LoadConfig(cConfigName);
  dmMetaData := TdmMetaData.Create(self);
  try
    dmMetaData.MasterConnection := FMasterFrame.Connection;
    dmMetaData.ConfigureMaster;
  finally
    dmMetaData.Free;
  end;}
end;

procedure TfmConfig.RefreshGUI;
begin
  edConfigName.Enabled := lNewConfig;

  edConfigName.Text := dmConfig.ConfigName;
  edFrenquency.Text := IntToStr(dmConfig.SyncFrequency);
  cbTrackChanges.Checked := dmConfig.TrackChanges;

  if dmConfig.ExcludedTables = '' then
    rbAllTables.Checked := True
  else
    rbExcludeSelectedTables.Checked := True;

  if dmConfig.MetaDataCreated then begin
    lbMetaDataStatus.Caption := _('LiveMirror meta-data has been CREATED in master database.');
    lbAddRemoveMetaData.Caption := _('Remove meta-data');
  end
  else begin
    lbMetaDataStatus.Caption := _('LiveMirror meta-data has been NOT BEEN created in master database.');
    lbAddRemoveMetaData.Caption := _('Create meta-data now');
  end;

  cbMasterDBType.ItemIndex := cbMasterDBType.Items.IndexOf(dmConfig.MasterDBTypeDescription);
  cbMirrorDBType.ItemIndex := cbMirrorDBType.Items.IndexOf(dmConfig.MirrorDBTypeDescription);

  if FileExists(GetErrorOptionsPath) then
    cbCustomErrorManagement.Checked := True
  else
    cbDefaultErrorReporting.Checked := True;
end;

end.
