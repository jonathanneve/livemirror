object LiveMirror: TLiveMirror
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'Microtec LiveMirror'
  StartType = stManual
  OnExecute = ServiceExecute
  Height = 276
  Width = 419
end
