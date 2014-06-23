object fmConfigOptions: TfmConfigOptions
  Left = 0
  Top = 0
  Caption = 'Synchronization options'
  ClientHeight = 397
  ClientWidth = 431
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
    Width = 104
    Height = 13
    Caption = 'Tables to synchronize'
  end
  object Label2: TLabel
    Left = 233
    Top = 8
    Width = 75
    Height = 13
    Caption = 'Excluded tables'
  end
  object btExclude: TSpeedButton
    Left = 204
    Top = 168
    Width = 23
    Height = 22
    Caption = '>'
    OnClick = btExcludeClick
  end
  object btInclude: TSpeedButton
    Left = 204
    Top = 196
    Width = 23
    Height = 22
    Caption = '<'
    OnClick = btIncludeClick
  end
  object lbTablesIncluded: TListBox
    Left = 8
    Top = 27
    Width = 190
    Height = 331
    ItemHeight = 13
    Items.Strings = (
      'edfzef'
      'qefzefzef'
      'zefzefze')
    MultiSelect = True
    TabOrder = 0
    OnDblClick = btExcludeClick
  end
  object lbTablesExcluded: TListBox
    Left = 233
    Top = 27
    Width = 190
    Height = 331
    ItemHeight = 13
    Items.Strings = (
      'edfzef'
      'qefzefzef'
      'zefzefze')
    MultiSelect = True
    TabOrder = 1
    OnDblClick = btIncludeClick
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
end
