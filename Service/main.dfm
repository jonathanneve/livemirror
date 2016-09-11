object LiveMirror: TLiveMirror
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'Microtec LiveMirror'
  StartType = stManual
  OnExecute = ServiceExecute
  OnShutdown = ServiceShutdown
  Height = 276
  Width = 419
end
