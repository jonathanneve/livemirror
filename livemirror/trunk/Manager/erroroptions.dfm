object fmErrorOptions: TfmErrorOptions
  Left = 0
  Top = 0
  Caption = 'Error management options'
  ClientHeight = 333
  ClientWidth = 952
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    952
    333)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 120
    Width = 936
    Height = 171
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Row-level errors'
    TabOrder = 0
    inline frLockError: TfrErrorConfig
      Left = 2
      Top = 15
      Width = 932
      Height = 50
      Align = alTop
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 932
      DesignSize = (
        932
        50)
      inherited edEmails: TEdit
        Width = 277
        ExplicitWidth = 277
      end
    end
    inline frFKError: TfrErrorConfig
      Left = 2
      Top = 65
      Width = 932
      Height = 50
      Align = alTop
      TabOrder = 1
      ExplicitLeft = 2
      ExplicitTop = 65
      ExplicitWidth = 932
      DesignSize = (
        932
        50)
      inherited edEmails: TEdit
        Width = 277
        ExplicitWidth = 277
      end
    end
    inline frOtherRowError: TfrErrorConfig
      Left = 2
      Top = 115
      Width = 932
      Height = 50
      Align = alTop
      TabOrder = 2
      ExplicitLeft = 2
      ExplicitTop = 115
      ExplicitWidth = 932
      inherited edEmails: TEdit
        Width = 277
        ExplicitWidth = 277
      end
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 936
    Height = 107
    Anchors = [akLeft, akTop, akRight]
    Caption = 'General errors'
    TabOrder = 1
    inline frConnectionError: TfrGeneralErrorConfig
      Left = 2
      Top = 15
      Width = 932
      Height = 46
      Align = alTop
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 932
      inherited Label1: TLabel
        Top = 2
        ExplicitTop = 2
      end
      inherited Label2: TLabel
        Left = 615
        Top = 20
        ExplicitLeft = 615
        ExplicitTop = 20
      end
      inherited Label3: TLabel
        Left = 584
        Top = 2
        Anchors = [akTop, akRight]
        ExplicitLeft = 584
        ExplicitTop = 2
      end
      inherited edEmails: TEdit
        Top = 16
        Width = 419
        ExplicitTop = 16
        ExplicitWidth = 419
      end
      inherited edReportAgainMin: TEdit
        Left = 584
        Top = 16
        Anchors = [akTop, akRight]
        ExplicitLeft = 584
        ExplicitTop = 16
      end
      inherited cbReportWhenResolved: TCheckBox
        Left = 733
        Top = 13
        Anchors = [akTop, akRight]
        ExplicitLeft = 733
        ExplicitTop = 13
      end
    end
    inline frOtherGeneralError: TfrGeneralErrorConfig
      Left = 2
      Top = 61
      Width = 932
      Height = 46
      Align = alTop
      TabOrder = 1
      ExplicitLeft = 2
      ExplicitTop = 61
      ExplicitWidth = 932
      inherited Label2: TLabel
        Left = 615
        ExplicitLeft = 615
      end
      inherited Label3: TLabel
        Left = 584
        Anchors = [akTop, akRight]
        ExplicitLeft = 584
      end
      inherited edEmails: TEdit
        Width = 419
        ExplicitWidth = 419
      end
      inherited edReportAgainMin: TEdit
        Left = 584
        Anchors = [akTop, akRight]
        ExplicitLeft = 584
      end
      inherited cbReportWhenResolved: TCheckBox
        Left = 733
        Anchors = [akTop, akRight]
        ExplicitLeft = 733
      end
    end
  end
  object Button1: TButton
    Left = 832
    Top = 301
    Width = 112
    Height = 25
    Caption = 'Close'
    ModalResult = 8
    TabOrder = 2
  end
end
