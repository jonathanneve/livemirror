object frConnectParamsFireDAC: TfrConnectParamsFireDAC
  Left = 0
  Top = 0
  Width = 454
  Height = 120
  TabOrder = 0
  DesignSize = (
    454
    120)
  object Label1: TLabel
    Left = 8
    Top = 65
    Width = 82
    Height = 13
    Caption = 'Database name :'
  end
  object Label2: TLabel
    Left = 8
    Top = 87
    Width = 58
    Height = 13
    Caption = 'User name :'
  end
  object Label3: TLabel
    Left = 203
    Top = 87
    Width = 53
    Height = 13
    Caption = 'Password :'
  end
  object Label5: TLabel
    Left = 8
    Top = 40
    Width = 68
    Height = 13
    Caption = 'Server name :'
  end
  object edDBName: TEdit
    Left = 96
    Top = 62
    Width = 344
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object edUserName: TEdit
    Left = 96
    Top = 84
    Width = 98
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 1
  end
  object edPassword: TEdit
    Left = 279
    Top = 84
    Width = 161
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    PasswordChar = '*'
    TabOrder = 2
  end
  object btTest: TButton
    Left = 338
    Top = 31
    Width = 104
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Test connect'
    TabOrder = 3
    OnClick = btTestClick
  end
  object edServerName: TEdit
    Left = 96
    Top = 37
    Width = 236
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
  end
  object Button1: TButton
    Left = 8
    Top = 6
    Width = 161
    Height = 25
    Caption = 'Configure connection'
    TabOrder = 5
    OnClick = Button1Click
  end
end
