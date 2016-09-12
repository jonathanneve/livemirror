object fmErrorOptions: TfmErrorOptions
  Left = 0
  Top = 0
  Caption = 'fmErrorOptions'
  ClientHeight = 334
  ClientWidth = 952
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    952
    334)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 120
    Width = 936
    Height = 162
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Row-level errors'
    TabOrder = 0
    DesignSize = (
      936
      162)
    object Label1: TLabel
      Left = 16
      Top = 31
      Width = 130
      Height = 33
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
      Top = 15
      Width = 85
      Height = 13
      Caption = 'Report error to...'
    end
    object Label3: TLabel
      Left = 248
      Top = 15
      Width = 36
      Height = 13
      Caption = 'Then...'
    end
    object Label4: TLabel
      Left = 423
      Top = 15
      Width = 154
      Height = 13
      Caption = 'Try again next replication cycle?'
    end
    object Label5: TLabel
      Left = 16
      Top = 70
      Width = 130
      Height = 34
      AutoSize = False
      Caption = 'Foreign key violations'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
    end
    object Label10: TLabel
      Left = 152
      Top = 15
      Width = 74
      Height = 13
      Caption = 'Try again for...'
    end
    object Label11: TLabel
      Left = 183
      Top = 32
      Width = 39
      Height = 13
      Caption = 'seconds'
    end
    object Label6: TLabel
      Left = 647
      Top = 63
      Width = 85
      Height = 13
      Caption = 'Report error to...'
    end
    object Label7: TLabel
      Left = 248
      Top = 63
      Width = 36
      Height = 13
      Caption = 'Then...'
    end
    object Label8: TLabel
      Left = 423
      Top = 63
      Width = 154
      Height = 13
      Caption = 'Try again next replication cycle?'
    end
    object Label9: TLabel
      Left = 152
      Top = 63
      Width = 74
      Height = 13
      Caption = 'Try again for...'
    end
    object Label12: TLabel
      Left = 183
      Top = 80
      Width = 39
      Height = 13
      Caption = 'seconds'
    end
    object Label13: TLabel
      Left = 16
      Top = 118
      Width = 130
      Height = 34
      AutoSize = False
      Caption = 'Other errors'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
    end
    object Label14: TLabel
      Left = 647
      Top = 111
      Width = 85
      Height = 13
      Caption = 'Report error to...'
    end
    object Label15: TLabel
      Left = 248
      Top = 111
      Width = 36
      Height = 13
      Caption = 'Then...'
    end
    object Label16: TLabel
      Left = 152
      Top = 111
      Width = 74
      Height = 13
      Caption = 'Try again for...'
    end
    object Label17: TLabel
      Left = 183
      Top = 128
      Width = 39
      Height = 13
      Caption = 'seconds'
    end
    object Label18: TLabel
      Left = 423
      Top = 111
      Width = 154
      Height = 13
      Caption = 'Try again next replication cycle?'
    end
    object Edit1: TEdit
      Left = 647
      Top = 29
      Width = 281
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      TextHint = 'Email address(es)'
      ExplicitWidth = 338
    end
    object ComboBox1: TComboBox
      Left = 248
      Top = 29
      Width = 169
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 1
      Text = 'Continue replication'
      Items.Strings = (
        'Abort replication'
        'Continue replication')
    end
    object ComboBox2: TComboBox
      Left = 423
      Top = 29
      Width = 218
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = 'No, report immediately'
      Items.Strings = (
        'No, report immediately'
        'Yes, report if it still fails')
    end
    object Edit3: TEdit
      Left = 152
      Top = 29
      Width = 25
      Height = 21
      TabOrder = 3
      Text = '5'
    end
    object Edit2: TEdit
      Left = 647
      Top = 77
      Width = 281
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      TextHint = 'Email address(es)'
    end
    object ComboBox3: TComboBox
      Left = 248
      Top = 77
      Width = 169
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 5
      Text = 'Continue replication'
      Items.Strings = (
        'Abort replication'
        'Continue replication')
    end
    object ComboBox4: TComboBox
      Left = 423
      Top = 77
      Width = 218
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 6
      Text = 'No, report immediately'
      Items.Strings = (
        'No, report immediately'
        'Yes, report if it still fails')
    end
    object Edit4: TEdit
      Left = 152
      Top = 77
      Width = 25
      Height = 21
      TabOrder = 7
      Text = '0'
    end
    object Edit5: TEdit
      Left = 647
      Top = 125
      Width = 281
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 8
      TextHint = 'Email address(es)'
    end
    object ComboBox5: TComboBox
      Left = 248
      Top = 125
      Width = 169
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 9
      Text = 'Continue replication'
      Items.Strings = (
        'Abort replication'
        'Continue replication')
    end
    object ComboBox6: TComboBox
      Left = 423
      Top = 125
      Width = 218
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 10
      Text = 'No, report immediately'
      Items.Strings = (
        'No, report immediately'
        'Yes, report if it still fails')
    end
    object Edit6: TEdit
      Left = 152
      Top = 125
      Width = 25
      Height = 21
      TabOrder = 11
      Text = '0'
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 936
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = 'General errors'
    TabOrder = 1
    ExplicitWidth = 619
  end
end
