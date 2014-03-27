object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Uninstalling LiveMirror services'
  ClientHeight = 282
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object memLog: TMemo
    Left = 0
    Top = 0
    Width = 418
    Height = 282
    Align = alClient
    ReadOnly = True
    TabOrder = 0
    ExplicitLeft = 144
    ExplicitTop = 120
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
  object ShowTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ShowTimerTimer
    Left = 80
    Top = 24
  end
end
