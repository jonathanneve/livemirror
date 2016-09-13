object frErrorConfig: TfrErrorConfig
  Left = 0
  Top = 0
  Width = 902
  Height = 50
  TabOrder = 0
  DesignSize = (
    902
    50)
  object lbErrorType: TLabel
    Left = 8
    Top = 13
    Width = 130
    Height = 31
    AutoSize = False
    Caption = 'Lock violations'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 647
    Top = 7
    Width = 85
    Height = 13
    Caption = 'Report error to...'
  end
  object Label3: TLabel
    Left = 248
    Top = 7
    Width = 36
    Height = 13
    Caption = 'Then...'
  end
  object Label4: TLabel
    Left = 423
    Top = 7
    Width = 195
    Height = 13
    Caption = 'Report after second replication attempt?'
  end
  object Label5: TLabel
    Left = 152
    Top = 7
    Width = 74
    Height = 13
    Caption = 'Try again for...'
  end
  object Label6: TLabel
    Left = 183
    Top = 24
    Width = 39
    Height = 13
    Caption = 'seconds'
  end
  object edEmails: TEdit
    Left = 647
    Top = 21
    Width = 247
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    TextHint = 'Email address(es)'
    OnExit = edTryAgainSecondsExit
  end
  object cbCanContinue: TComboBox
    Left = 248
    Top = 21
    Width = 169
    Height = 21
    Style = csDropDownList
    ItemIndex = 1
    TabOrder = 1
    Text = 'Continue replication'
    OnExit = edTryAgainSecondsExit
    Items.Strings = (
      'Abort replication'
      'Continue replication')
  end
  object cbTryNextCycle: TComboBox
    Left = 423
    Top = 21
    Width = 218
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 2
    Text = 'No, report immediately'
    OnExit = edTryAgainSecondsExit
    Items.Strings = (
      'No, report immediately'
      'Yes, report if it still fails')
  end
  object edTryAgainSeconds: TEdit
    Left = 152
    Top = 21
    Width = 25
    Height = 21
    TabOrder = 0
    Text = '5'
    OnExit = edTryAgainSecondsExit
  end
end
