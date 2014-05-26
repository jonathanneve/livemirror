program LiveMirrorSrvTester;

uses
  Vcl.Forms,
  LiveMirrorSrvTest in 'LiveMirrorSrvTest.pas' {Form1},
  dInterbase in 'dInterbase.pas' {dmInterbase: TDataModule},
  HotLog in 'HotLog.pas',
  main in 'main.pas' {LiveMirror: TService},
  gnugettext in '..\gnugettext.pas',
  LMUtils in '..\LMUtils.pas',
  ServiceManager in '..\ServiceManager.pas',
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
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TdmInterbase, dmInterbase);
  Application.CreateForm(TLiveMirror, LiveMirror);
  Application.Run;
end.
