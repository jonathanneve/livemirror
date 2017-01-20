program LiveMirrorMgr;

{$R 'version.res' '..\version.rc'}

uses
  EMemLeaks,
  EResLeaks,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  EDebugExports,
  EDebugJCL,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  Vcl.Forms,
  config in 'config.pas' {fmConfig},
  configs in 'configs.pas' {fmConfigs},
  fConnectParamsFB in 'fConnectParamsFB.pas' {frConnectParamsFB: TFrame},
  LMUtils in '..\LMUtils.pas',
  ServiceManager in '..\ServiceManager.pas',
  gnugettext in '..\gnugettext.pas',
  uLkJSON in '..\uLkJSON.pas',
  blcksock in '..\Synapse\blcksock.pas',
  httpsend in '..\Synapse\httpsend.pas',
  synacode in '..\Synapse\synacode.pas',
  synaip in '..\Synapse\synaip.pas',
  synautil in '..\Synapse\synautil.pas',
  synsock in '..\Synapse\synsock.pas',
  synafpc in '..\Synapse\synafpc.pas',
  licensing in 'licensing.pas' {fmLicensing},
  Vcl.Themes,
  Vcl.Styles,
  logfile in 'logfile.pas' {fmLogFile},
  configoptions in 'configoptions.pas' {fmConfigOptions},
  dconfig in '..\dconfig.pas' {dmConfig: TDataModule},
  dInterbase in '..\dInterbase.pas' {dmInterbase: TDataModule},
  fConnectParamsFireDAC in 'fConnectParamsFireDAC.pas' {frConnectParamsFireDAC: TFrame},
  dFireDAC in '..\dFireDAC.pas' {dmFireDAC: TDataModule},
  FireDAC.VCLUI.OptsBase in 'C:\Program Files (x86)\Embarcadero\Studio\14.0\source\data\firedac\FireDAC.VCLUI.OptsBase.pas' {frmFDGUIxFormsOptsBase},
  FireDAC.VCLUI.ConnEdit in 'FireDAC.VCLUI.ConnEdit.pas' {frmFDGUIxFormsConnEdit},
  erroroptions in 'erroroptions.pas' {fmErrorOptions},
  errors in '..\errors.pas',
  fErrorConfig in 'fErrorConfig.pas' {frErrorConfig: TFrame},
  fGeneralErrorConfig in 'fGeneralErrorConfig.pas' {frGeneralErrorConfig: TFrame},
  configfields in 'configfields.pas' {fmConfigFields};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  TStyleManager.TrySetStyle('Light');
  Application.Title := 'LiveMirror Manager';
  Application.CreateForm(TfmConfigs, fmConfigs);
  Application.CreateForm(TdmInterbase, dmInterbase);
  Application.CreateForm(TdmFireDAC, dmFireDAC);
  Application.CreateForm(TfrmFDGUIxFormsOptsBase, frmFDGUIxFormsOptsBase);
  Application.CreateForm(TfrmFDGUIxFormsConnEdit, frmFDGUIxFormsConnEdit);
  Application.Run;
end.
