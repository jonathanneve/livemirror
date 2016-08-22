object dmFireDACSQLite: TdmFireDACSQLite
  OldCreateOrder = False
  Height = 402
  Width = 611
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
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
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 248
    Top = 168
  end
  object CcConnection: TCcConnectionFDSQLite
    FDConnection = FDConnection
    FDTransaction = FDTransaction
    DriverLink = FDPhysSQLiteDriverLink1
    DBVersion = '3.x'
    Left = 48
    Top = 80
  end
end
