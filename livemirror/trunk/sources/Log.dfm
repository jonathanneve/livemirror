object fmLog: TfmLog
  Left = 285
  Top = 165
  BorderStyle = bsToolWindow
  Caption = 'Log'
  ClientHeight = 590
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TRzPanel
    Left = 0
    Top = 553
    Width = 688
    Height = 37
    Align = alBottom
    BorderOuter = fsFlatRounded
    TabOrder = 0
    DesignSize = (
      688
      37)
    object btnClose: TRzBitBtn
      Left = 573
      Top = 6
      Width = 106
      Anchors = [akTop, akRight]
      Caption = 'Close'
      Color = 15791348
      HighlightColor = 16026986
      HotTrack = True
      HotTrackColor = 3983359
      TabOrder = 0
      OnClick = btnCloseClick
      Kind = bkCancel
    end
  end
  object pnlInfos: TRzPanel
    Left = 0
    Top = 0
    Width = 688
    Height = 49
    Align = alTop
    BorderOuter = fsFlatRounded
    TabOrder = 1
    object lblAliasName: TRzLabel
      Left = 8
      Top = 8
      Width = 73
      Height = 13
      AutoSize = False
      Caption = 'Alias name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblStatus: TRzLabel
      Left = 8
      Top = 24
      Width = 73
      Height = 13
      AutoSize = False
      Caption = 'Status'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblAliasNameValue: TRzLabel
      Left = 88
      Top = 8
      Width = 593
      Height = 13
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblStatusValue: TRzLabel
      Left = 88
      Top = 24
      Width = 593
      Height = 13
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
end
