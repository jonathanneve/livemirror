object dmFireDAC: TdmFireDAC
  OldCreateOrder = False
  Height = 373
  Width = 630
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    TxOptions.AutoStop = False
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
  object CcConnection: TCcConnectionFireDAC
    FDConnection = FDConnection
    FDTransaction = FDTransaction
    DBType = 'MySQL'
    Left = 48
    Top = 80
  end
  object FDMoniFlatFileClientLink: TFDMoniFlatFileClientLink
    ShowTraces = False
    Left = 216
    Top = 72
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 136
    Top = 208
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 296
    Top = 168
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 304
    Top = 224
  end
end
