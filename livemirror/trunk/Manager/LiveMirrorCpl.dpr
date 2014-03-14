library LiveMirrorCpl;

uses
  CtlPanel,
  main in 'main.pas' {LiveMirrorManager: TAppletModule},
  LMUtils in '..\LMUtils.pas',
  gnugettext in '..\gnugettext.pas';

exports CPlApplet;

{$R *.RES}

{$E cpl}

begin
  Application.Initialize;
  Application.CreateForm(TLiveMirrorManager, LiveMirrorManager);
  Application.Run;
end.