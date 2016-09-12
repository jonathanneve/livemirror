program LiveMirrorSrv;

{$R 'version.res' '..\version.rc'}

uses
  Vcl.SvcMgr,
  main in 'main.pas' {LiveMirror: TService},
  LMUtils in '..\LMUtils.pas',
  gnugettext in '..\gnugettext.pas',
  uLkJSON in '..\uLkJSON.pas',
  blcksock in '..\Synapse\blcksock.pas',
  httpsend in '..\Synapse\httpsend.pas',
  synacode in '..\Synapse\synacode.pas',
  synafpc in '..\Synapse\synafpc.pas',
  synaip in '..\Synapse\synaip.pas',
  synautil in '..\Synapse\synautil.pas',
  synsock in '..\Synapse\synsock.pas',
  dInterbase in '..\dInterbase.pas' {dmInterbase: TDataModule},
  dconfig in '..\dconfig.pas' {dmConfig: TDataModule},
  dFireDAC in '..\dFireDAC.pas' {dmFireDAC: TDataModule},
  dLiveMirrorNode in 'dLiveMirrorNode.pas' {dmLiveMirrorNode: TDataModule},
  LiveMirrorRunnerThread in 'LiveMirrorRunnerThread.pas';

{$R *.RES}

begin
  // Windows 2003 Server n�cessite que StartServiceCtrlDispatcher soit
  // appel� avant CoRegisterClassObject, qui peut �tre appel� indirectement
  // par Application.Initialize. TServiceApplication.DelayInitialize permet
  // l'appel de Application.Initialize depuis TService.Main (apr�s
  // l'appel de StartServiceCtrlDispatcher).
  //
  // L'initialisation diff�r�e de l'objet Application peut affecter
  // les �v�nements qui surviennent alors avant l'initialisation, tels que
  // TService.OnCreate. Elle est seulement recommand�e si le ServiceApplication
  // enregistre un objet de classe avec OLE et est destin�e � une utilisation
  // avec Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TLiveMirror, LiveMirror);
  Application.CreateForm(TdmInterbase, dmInterbase);
  Application.CreateForm(TdmFireDAC, dmFireDAC);
  Application.CreateForm(TdmLiveMirrorNode, dmLiveMirrorNode);
  Application.Run;
end.
