object fmConfigFields: TfmConfigFields
  Left = 0
  Top = 0
  Caption = 'Field exlusions'
  ClientHeight = 393
  ClientWidth = 429
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Tables'
  end
  object Label2: TLabel
    Left = 224
    Top = 8
    Width = 80
    Height = 13
    Caption = 'Fields to exclude'
  end
  object SpeedButton1: TSpeedButton
    Left = 398
    Top = 26
    Width = 23
    Height = 22
    Caption = '+'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = SpeedButton1Click
  end
  object lbTables: TListBox
    Left = 8
    Top = 27
    Width = 201
    Height = 331
    ItemHeight = 13
    Items.Strings = (
      'edfzef'
      'qefzefzef'
      'zefzefze')
    MultiSelect = True
    TabOrder = 0
    OnClick = lbTablesClick
  end
  object lbExcludedFields: TListBox
    Left = 224
    Top = 54
    Width = 197
    Height = 304
    ItemHeight = 13
    Items.Strings = (
      'edfzef'
      'qefzefzef'
      'zefzefze')
    MultiSelect = True
    TabOrder = 1
  end
  object Button1: TButton
    Left = 348
    Top = 364
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button2: TButton
    Left = 267
    Top = 364
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
  object cbFieldName: TComboBox
    Left = 224
    Top = 27
    Width = 174
    Height = 21
    Style = csDropDownList
    TabOrder = 4
  end
end
