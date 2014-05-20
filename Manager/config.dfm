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
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    433
    241)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 101
    Height = 13
    Caption = 'Configuration name :'
  end
  object lbEvaluation: TLabel
    Left = 12
    Top = 211
    Width = 223
    Height = 23
    Caption = 'EVALUATION VERSION'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edFrenquency: TLabeledEdit
    Left = 269
    Top = 24
    Width = 156
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
  object edConfigName: TMaskEdit
    Left = 8
    Top = 24
    Width = 127
    Height = 21
    EditMask = '>aaaaaaaaaaaaa;0; '
    MaxLength = 13
    TabOrder = 0
    Text = ''
  end
  object btLicensing: TButton
    Left = 8
    Top = 208
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Licensing'
    TabOrder = 5
    OnClick = btLicensingClick
  end
end
