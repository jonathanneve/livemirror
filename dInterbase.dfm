object dmInterbase: TdmInterbase
  OldCreateOrder = False
  Height = 304
  Width = 355
  object FDConnection: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Transaction = FDTransaction
    UpdateTransaction = FDTransaction
    Left = 48
    Top = 24
  end
  object FDTransaction: TFDTransaction
    Options.AutoStop = False
    Connection = FDConnection
    Left = 176
    Top = 24
  end
  object FDPhysIBDriverLink: TFDPhysIBDriverLink
    Left = 128
    Top = 136
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 256
    Top = 136
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 136
    Top = 208
  end
  object CcConnection: TCcConnectionFireDAC
    FDConnection = FDConnection
    FDTransaction = FDTransaction
    DBType = 'Interbase'
    Left = 48
    Top = 80
  end
  object FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink
    ShowTraces = False
    Left = 216
    Top = 72
  end
end
