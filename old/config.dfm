object fmConfig: TfmConfig
  Left = 0
  Top = 0
  Caption = 'Setup backup configuration'
  ClientHeight = 241
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    433
    241)
  PixelsPerInch = 96
  TextHeight = 13
  object edConfigName: TLabeledEdit
    Left = 8
    Top = 24
    Width = 225
    Height = 21
    EditLabel.Width = 94
    EditLabel.Height = 13
    EditLabel.Caption = 'Configuration name'
    TabOrder = 0
  end
  object edFrenquency: TLabeledEdit
    Left = 318
    Top = 24
    Width = 107
    Height = 21
    Anchors = [akTop, akRight]
    EditLabel.Width = 102
    EditLabel.Height = 13
    EditLabel.Caption = 'Sync frequency (sec)'
    NumbersOnly = True
    TabOrder = 1
    Text = '30'
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 51
    Width = 418
    Height = 154
    ActivePage = tsMaster
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object tsMaster: TTabSheet
      Caption = 'Master database'
    end
    object tsMirror: TTabSheet
      Caption = 'Mirror database'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 281
      ExplicitHeight = 165
    end
  end
  object Button3: TButton
    Left = 350
    Top = 208
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object Button4: TButton
    Left = 269
    Top = 208
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 4
  end
end
