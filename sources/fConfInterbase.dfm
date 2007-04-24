object frConfInterbase: TfrConfInterbase
  Left = 0
  Top = 0
  Width = 400
  Height = 31
  TabOrder = 0
  object pnInterbase: TRzPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 31
    Align = alClient
    BorderOuter = fsNone
    TabOrder = 0
    Transparent = True
    DesignSize = (
      400
      31)
    object Label10: TLabel
      Left = 11
      Top = 6
      Width = 61
      Height = 13
      Caption = 'SQL dialect :'
      Transparent = True
    end
    object Label1: TLabel
      Left = 227
      Top = 7
      Width = 55
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Client DLL :'
      Transparent = True
    end
    object edLocalSQLDialect: TRzDBEdit
      Tag = 1
      Left = 92
      Top = 3
      Width = 73
      Height = 21
      DataField = 'SQLDialect'
      Alignment = taRightJustify
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 0
    end
    object RzDBEdit1: TRzDBEdit
      Tag = 1
      Left = 286
      Top = 3
      Width = 112
      Height = 21
      DataField = 'ClientDLL'
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 1
    end
  end
end
