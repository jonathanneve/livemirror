program LiveMirrorUninstaller;

uses
  Vcl.Forms,
  uninst_main in 'uninst_main.pas' {fmMain},
  gnugettext in '..\gnugettext.pas',
  LMUtils in '..\LMUtils.pas',
  uLkJSON in '..\uLkJSON.pas',
  blcksock in '..\Synapse\blcksock.pas',
  httpsend in '..\Synapse\httpsend.pas',
  synacode in '..\Synapse\synacode.pas',
  synafpc in '..\Synapse\synafpc.pas',
  synaip in '..\Synapse\synaip.pas',
  synautil in '..\Synapse\synautil.pas',
  synsock in '..\Synapse\synsock.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
