object fmErrorOptions: TfmErrorOptions
  Left = 0
  Top = 0
  Caption = 'Error management options'
  ClientHeight = 400
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
    400)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 185
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
    Top = 73
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
      DesignSize = (
        932
        46)
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
      DesignSize = (
        932
        46)
    end
  end
  object Button1: TButton
    Left = 832
    Top = 366
    Width = 112
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Close'
    ModalResult = 8
    TabOrder = 2
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 8
    Width = 937
    Height = 57
    Caption = 'Status report'
    TabOrder = 3
    object Label2: TLabel
      Left = 345
      Top = 25
      Width = 81
      Height = 13
      Caption = 'replication cycles'
    end
    object Label1: TLabel
      Left = 569
      Top = 25
      Width = 74
      Height = 13
      Caption = 'Send report to:'
    end
    object Label3: TLabel
      Left = 10
      Top = 25
      Width = 250
      Height = 13
      Caption = 'Send an email to confirm status of replication every:'
    end
    object Edit1: TEdit
      Left = 306
      Top = 22
      Width = 33
      Height = 21
      TabOrder = 0
      Text = '1'
    end
    object Edit2: TEdit
      Left = 649
      Top = 22
      Width = 277
      Height = 21
      TabOrder = 1
      TextHint = 'Email address(es)'
    end
  end
end
