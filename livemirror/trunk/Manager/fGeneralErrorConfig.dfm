object frGeneralErrorConfig: TfrGeneralErrorConfig
  Left = 0
  Top = 0
  Width = 903
  Height = 46
  TabOrder = 0
  DesignSize = (
    903
    46)
  object lbErrorType: TLabel
    Left = 8
    Top = 13
    Width = 130
    Height = 33
    AutoSize = False
    Caption = 'Connection errors'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label1: TLabel
    Left = 431
    Top = 7
    Width = 85
    Height = 13
    Caption = 'Report error to...'
  end
  object Label2: TLabel
    Left = 649
    Top = 25
    Width = 37
    Height = 13
    Caption = 'minutes'
  end
  object Label3: TLabel
    Left = 614
    Top = 7
    Width = 105
    Height = 13
    Caption = 'Report again every...'
  end
  object Label4: TLabel
    Left = 152
    Top = 7
    Width = 74
    Height = 13
    Caption = 'Try again for...'
  end
  object Label5: TLabel
    Left = 183
    Top = 24
    Width = 39
    Height = 13
    Caption = 'seconds'
  end
  object Label6: TLabel
    Left = 235
    Top = 7
    Width = 102
    Height = 13
    Caption = 'Try again next cycle?'
  end
  object edEmails: TEdit
    Left = 431
    Top = 22
    Width = 176
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    TextHint = 'Email address(es)'
    OnExit = edEmailsExit
  end
  object edReportAgainMin: TEdit
    Left = 613
    Top = 21
    Width = 25
    Height = 22
    TabOrder = 1
    Text = '5'
    OnExit = edEmailsExit
  end
  object cbReportWhenResolved: TCheckBox
    Left = 732
    Top = 16
    Width = 167
    Height = 16
    Caption = 'Report when resolved'
    TabOrder = 2
    OnExit = edEmailsExit
  end
  object edTryAgainSeconds: TEdit
    Left = 152
    Top = 21
    Width = 25
    Height = 21
    TabOrder = 3
    Text = '5'
  end
  object cbTryNextCycle: TComboBox
    Left = 235
    Top = 21
    Width = 190
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 4
    Text = 'No, report immediately'
    Items.Strings = (
      'No, report immediately'
      'Yes, report if it still fails')
  end
end
