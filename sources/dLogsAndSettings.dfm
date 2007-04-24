object dmLogsAndSettings: TdmLogsAndSettings
  OldCreateOrder = False
  Left = 414
  Top = 271
  Height = 151
  Width = 426
  object CcReplicatorList1: TCcReplicatorList
    Version = '2.00.0'
    Left = 40
    Top = 64
  end
  object CcConfigStorage: TCcConfigStorage
    Left = 128
    Top = 8
  end
  object CcDataSet1: TCcDataSet
    Left = 128
    Top = 64
  end
  object CcConfig: TCcConfig
    ConfigStorage = CcConfigStorage
    Version = '2.00.0'
    DatabaseNode = dnLocal
    Terminator = #167
    Left = 40
    Top = 8
  end
  object CcConfigStorageDS: TDataSource
    DataSet = CcConfigStorage
    Left = 232
    Top = 8
  end
  object FrameController: TRzFrameController
    DisabledColor = 14278369
    FocusColor = 13828095
    FrameColor = 12164479
    FrameHotTrack = True
    FrameVisible = True
    Left = 336
    Top = 8
  end
  object CcConnectionFIB1: TCcConnectionFIB
    TRParams.Strings = (
      'write'
      'nowait'
      'rec_version')
    ClientDLL = 'gds32.dll'
    Left = 232
    Top = 64
  end
  object CcConnectionADO1: TCcConnectionADO
    ConnectionTimeout = 15
    CommandTimeout = 30
    Left = 336
    Top = 64
  end
end
