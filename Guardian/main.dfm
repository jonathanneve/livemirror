object LiveMirror: TLiveMirror
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'Microtec LiveMirror'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  OnShutdown = ServiceShutdown
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
