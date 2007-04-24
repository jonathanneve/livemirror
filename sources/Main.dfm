object fmMain: TfmMain
  Left = 210
  Top = 178
  Width = 773
  Height = 526
  Caption = 'Microtec Live Mirror v1.00.0'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object RzBackground1: TRzBackground
    Left = 0
    Top = 0
    Width = 133
    Height = 499
    Active = True
    Align = alLeft
    GradientColorStart = clWhite
    ImageStyle = isCenter
    ShowGradient = True
    ShowImage = False
    ShowTexture = False
  end
  object RzLabel2: TRzLabel
    Left = 8
    Top = 141
    Width = 76
    Height = 332
    Caption = 'Live Mirror'
    Font.Charset = ANSI_CHARSET
    Font.Color = 39423
    Font.Height = -64
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Angle = 90
    CenterPoint = cpLowerLeft
    Rotation = roFlat
    TextStyle = tsShadow
  end
  object Image1: TImage
    Left = 4
    Top = 4
    Width = 125
    Height = 125
    Transparent = True
  end
  object RzLabel1: TRzLabel
    Left = 79
    Top = 135
    Width = 37
    Height = 9
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    Angle = 90
    CenterPoint = cpLowerLeft
    Rotation = roFlat
  end
  object pnlMain: TPanel
    Left = 133
    Top = 0
    Width = 632
    Height = 499
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      632
      499)
    object pnlButtons: TRzPanel
      Left = 3
      Top = 458
      Width = 627
      Height = 38
      Anchors = [akLeft, akRight]
      BorderOuter = fsFlatRounded
      TabOrder = 0
      DesignSize = (
        627
        38)
      object btnClose: TRzBitBtn
        Left = 513
        Top = 7
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
    object dbgResults: TDBGridEh
      Left = 3
      Top = 3
      Width = 627
      Height = 452
      DataSource = dmLogsAndSettings.CcConfigStorageDS
      FooterColor = clWindow
      FooterFont.Charset = DEFAULT_CHARSET
      FooterFont.Color = clWindowText
      FooterFont.Height = -11
      FooterFont.Name = 'MS Sans Serif'
      FooterFont.Style = []
      PopupMenu = popMain
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      Columns = <
        item
          EditButtons = <>
          FieldName = 'ConfigName'
          Footers = <>
          Width = 150
        end
        item
          EditButtons = <>
          Footers = <>
        end
        item
          EditButtons = <>
          Footers = <>
        end>
    end
  end
  object ActionList: TActionList
    Left = 8
    Top = 464
    object actNew: TAction
      Caption = 'New'
      OnExecute = actNewExecute
    end
    object actEdit: TAction
      Caption = 'Edit'
    end
    object actDelete: TAction
      Caption = 'Delete'
    end
    object actRefreshConfig: TAction
      Caption = 'Refresh config'
    end
    object actReplicateNow: TAction
      Caption = 'Replicate now !'
    end
    object actViewLog: TAction
      Caption = 'View log'
      OnExecute = actViewLogExecute
    end
  end
  object popMain: TPopupMenu
    Left = 48
    Top = 464
    object mnuViewLog: TMenuItem
      Action = actViewLog
      Default = True
    end
    object mnuSettings: TMenuItem
      Caption = 'Settings'
      object mnuNew: TMenuItem
        Action = actNew
      end
      object mnuEdit: TMenuItem
        Action = actEdit
      end
      object mnuDelete: TMenuItem
        Action = actDelete
      end
      object mnuRefreshConfig: TMenuItem
        Action = actRefreshConfig
      end
    end
    object mnuReplicateNow: TMenuItem
      Action = actReplicateNow
    end
  end
end
