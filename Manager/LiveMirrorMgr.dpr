program LiveMirrorMgr;

uses
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
  licensing in 'licensing.pas' {fmLicensing};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'LiveMirror Manager';
  Application.CreateForm(TfmConfigs, fmConfigs);
  Application.Run;
end.
