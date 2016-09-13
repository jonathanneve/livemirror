object frGeneralErrorConfig: TfrGeneralErrorConfig
  Left = 0
  Top = 0
  Width = 802
  Height = 46
  TabOrder = 0
  DesignSize = (
    802
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
    Left = 144
    Top = 6
    Width = 85
    Height = 13
    Caption = 'Report error to...'
  end
  object Label2: TLabel
    Left = 479
    Top = 23
    Width = 37
    Height = 13
    Caption = 'minutes'
  end
  object Label3: TLabel
    Left = 448
    Top = 6
    Width = 105
    Height = 13
    Caption = 'Report again every...'
  end
  object edEmails: TEdit
    Left = 144
    Top = 20
    Width = 289
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    TextHint = 'Email address(es)'
    OnExit = edEmailsExit
  end
  object edReportAgainMin: TEdit
    Left = 448
    Top = 20
    Width = 25
    Height = 21
    TabOrder = 1
    Text = '5'
    OnExit = edEmailsExit
  end
  object cbReportWhenResolved: TCheckBox
    Left = 597
    Top = 17
    Width = 196
    Height = 16
    Caption = 'Report when resolved'
    TabOrder = 2
    OnExit = edEmailsExit
  end
end
