library LiveMirrorCpl;

uses
  CtlPanel,
  main in 'main.pas' {LiveMirrorManager: TAppletModule},
  LMUtils in '..\LMUtils.pas',
  gnugettext in '..\gnugettext.pas',
  uLkJSON in '..\uLkJSON.pas',
  blcksock in '..\Synapse\blcksock.pas',
  httpsend in '..\Synapse\httpsend.pas',
  synacode in '..\Synapse\synacode.pas',
  synafpc in '..\Synapse\synafpc.pas',
  synaip in '..\Synapse\synaip.pas',
  synautil in '..\Synapse\synautil.pas',
  synsock in '..\Synapse\synsock.pas';

exports CPlApplet;

{$R *.RES}

{$E cpl}

begin
  Application.Initialize;
  Application.CreateForm(TLiveMirrorManager, LiveMirrorManager);
  Application.Run;
end.