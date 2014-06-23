object frConnectParamsFB: TfrConnectParamsFB
  Left = 0
  Top = 0
  Width = 451
  Height = 123
  TabOrder = 0
  DesignSize = (
    451
    123)
  object Label1: TLabel
    Left = 16
    Top = 33
    Width = 82
    Height = 13
    Caption = 'Database name :'
  end
  object SpeedButton1: TSpeedButton
    Left = 425
    Top = 30
    Width = 23
    Height = 22
    Anchors = [akTop, akRight]
    Caption = '...'
    OnClick = SpeedButton1Click
  end
  object Label2: TLabel
    Left = 16
    Top = 55
    Width = 58
    Height = 13
    Caption = 'User name :'
  end
  object Label3: TLabel
    Left = 211
    Top = 55
    Width = 53
    Height = 13
    Caption = 'Password :'
  end
  object Label4: TLabel
    Left = 16
    Top = 77
    Width = 45
    Height = 13
    Caption = 'Charset :'
  end
  object Label5: TLabel
    Left = 211
    Top = 77
    Width = 39
    Height = 13
    Caption = 'Dialect :'
  end
  object Label9: TLabel
    Left = 16
    Top = 99
    Width = 69
    Height = 13
    Caption = 'Library name :'
  end
  object SpeedButton2: TSpeedButton
    Left = 425
    Top = 95
    Width = 23
    Height = 22
    Anchors = [akTop, akRight]
    Caption = '...'
    OnClick = SpeedButton2Click
  end
  object Label10: TLabel
    Left = 16
    Top = 14
    Width = 42
    Height = 13
    Caption = 'Version :'
  end
  object edDBName: TEdit
    Left = 107
    Top = 30
    Width = 318
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object edUserName: TEdit
    Left = 107
    Top = 52
    Width = 98
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 2
  end
  object edPassword: TEdit
    Left = 287
    Top = 52
    Width = 161
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    PasswordChar = '*'
    TabOrder = 3
  end
  object cbDialect: TComboBox
    Left = 287
    Top = 74
    Width = 161
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemIndex = 2
    TabOrder = 5
    Text = '3'
    Items.Strings = (
      '1'
      '2'
      '3')
  end
  object edCharset: TEdit
    Left = 107
    Top = 74
    Width = 98
    Height = 21
    TabOrder = 4
  end
  object edClientDLL: TEdit
    Left = 107
    Top = 96
    Width = 318
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 6
  end
  object cbVersions: TComboBox
    Left = 107
    Top = 8
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 0
  end
  object btTest: TButton
    Left = 344
    Top = 3
    Width = 104
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Test connect'
    TabOrder = 7
    OnClick = btTestClick
  end
  object FDPhysFBDriverLinkOld: TFDPhysFBDriverLink
    Left = 240
    Top = 40
  end
  object OpenDialogDLL: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Windows library'
        FileMask = '*.dll'
      end
      item
        DisplayName = 'Any file'
        FileMask = '*.*'
      end>
    Options = []
    Left = 56
    Top = 16
  end
  object OpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Interbase databases'
        FileMask = '*.gdb'
      end
      item
        DisplayName = 'FireBird databases'
        FileMask = '*.fdb'
      end
      item
        DisplayName = 'Any file'
        FileMask = '*.*'
      end>
    FileTypeIndex = 2
    Options = []
    Left = 64
    Top = 56
  end
  object ConnectionOld: TCcConnectionFireDAC
    FDConnection = FDConnectionOld
    FDTransaction = FDTransaction1Old
    DBType = 'Interbase'
    Left = 208
    Top = 65528
  end
  object FDConnectionOld: TFDConnection
    Params.Strings = (
      'Database=fdl'
      'User_Name=sys'
      'Password=dfgdc'
      'SQLDialect=1'
      'DriverID=FB')
    LoginPrompt = False
    Transaction = FDTransaction1Old
    UpdateTransaction = FDTransaction1Old
    Left = 152
  end
  object FDTransaction1Old: TFDTransaction
    Connection = FDConnectionOld
    Left = 160
    Top = 48
  end
end
