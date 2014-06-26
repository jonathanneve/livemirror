program LiveMirrorSrv;

{$R 'version.res' '..\version.rc'}

uses
  EMemLeaks,
  EResLeaks,
  EDebugExports,
  EDebugJCL,
  EFixSafeCallException,
  EMapWin32,
  EAppService,
  ExceptionLog7,
  Vcl.SvcMgr,
  main in 'main.pas' {LiveMirror: TService},
  LMUtils in '..\LMUtils.pas',
  gnugettext in '..\gnugettext.pas',
  HotLog in 'HotLog.pas',
  uLkJSON in '..\uLkJSON.pas',
  blcksock in '..\Synapse\blcksock.pas',
  httpsend in '..\Synapse\httpsend.pas',
  synacode in '..\Synapse\synacode.pas',
  synafpc in '..\Synapse\synafpc.pas',
  synaip in '..\Synapse\synaip.pas',
  synautil in '..\Synapse\synautil.pas',
  synsock in '..\Synapse\synsock.pas',
  dInterbase in '..\dInterbase.pas' {dmInterbase: TDataModule},
  dconfig in '..\dconfig.pas' {dmConfig: TDataModule};

{$R *.RES}

begin
  // Windows 2003 Server nécessite que StartServiceCtrlDispatcher soit
  // appelé avant CoRegisterClassObject, qui peut être appelé indirectement
  // par Application.Initialize. TServiceApplication.DelayInitialize permet
  // l'appel de Application.Initialize depuis TService.Main (après
  // l'appel de StartServiceCtrlDispatcher).
  //
  // L'initialisation différée de l'objet Application peut affecter
  // les événements qui surviennent alors avant l'initialisation, tels que
  // TService.OnCreate. Elle est seulement recommandée si le ServiceApplication
  // enregistre un objet de classe avec OLE et est destinée à une utilisation
  // avec Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TLiveMirror, LiveMirror);
  Application.CreateForm(TdmInterbase, dmInterbase);
  Application.Run;
end.
