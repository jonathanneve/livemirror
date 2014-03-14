object fmConfigs: TfmConfigs
  Left = 0
  Top = 0
  Caption = 'LiveMirror Manager'
  ClientHeight = 213
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 334
    Height = 197
    Caption = 'Services'
    TabOrder = 0
    DesignSize = (
      334
      197)
    object listConfigs: TListBox
      Left = 3
      Top = 18
      Width = 239
      Height = 176
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
      OnDblClick = listConfigsDblClick
    end
    object Button1: TButton
      Left = 248
      Top = 18
      Width = 75
      Height = 25
      Caption = 'Add'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 248
      Top = 80
      Width = 75
      Height = 25
      Caption = 'Delete'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 248
      Top = 49
      Width = 75
      Height = 25
      Caption = 'Properties'
      TabOrder = 3
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 248
      Top = 111
      Width = 75
      Height = 25
      Caption = 'Start service'
      TabOrder = 4
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 248
      Top = 142
      Width = 75
      Height = 25
      Caption = 'Stop service'
      TabOrder = 5
    end
  end
end
