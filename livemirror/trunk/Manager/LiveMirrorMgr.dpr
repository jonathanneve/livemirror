program LiveMirrorMgr;

uses
  Vcl.Forms,
  config in 'config.pas' {fmConfig},
  configs in 'configs.pas' {fmConfigs},
  fConnectParamsFB in 'fConnectParamsFB.pas' {frConnectParamsFB: TFrame},
  LMUtils in '..\LMUtils.pas',
  ServiceManager in '..\ServiceManager.pas',
  gnugettext in '..\gnugettext.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'LiveMirror Manager';
  Application.CreateForm(TfmConfigs, fmConfigs);
  Application.Run;
end.
