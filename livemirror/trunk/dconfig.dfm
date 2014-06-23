object dmConfig: TdmConfig
  OldCreateOrder = False
  Height = 200
  Width = 312
  object MasterConfig: TCcConfig
    Version = '3.06.0'
    FailIfNoPK = False
    ConfigName = 'LM'
    DatabaseNode = dnLocal
    Terminator = #167
    Tables = <>
    Left = 24
    Top = 24
  end
  object MirrorConfig: TCcConfig
    Version = '3.06.0'
    FailIfNoPK = False
    ConfigName = 'LM'
    DatabaseNode = dnLocal
    Terminator = #167
    Tables = <>
    Left = 88
    Top = 24
  end
end
