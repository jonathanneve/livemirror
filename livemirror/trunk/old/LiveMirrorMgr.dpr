program LiveMirrorMgr;

uses
  gnugettext in 'gnugettext.pas',
  Vcl.Forms,
  config in 'config.pas' {fmConfig},
  configs in 'configs.pas' {fmConfigs},
  fConnectParamsFB in 'fConnectParamsFB.pas' {frConnectParamsFB: TFrame},
  LMUtils in 'LMUtils.pas',
  ServiceManager in 'ServiceManager.pas';

{$R *.res}

begin
  UseLanguage('fr');
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmConfigs, fmConfigs);
  Application.Run;
end.
