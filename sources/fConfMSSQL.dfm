object frConfMSSQL: TfrConfMSSQL
  Left = 0
  Top = 0
  Width = 400
  Height = 60
  TabOrder = 0
  object pnMSSQL: TRzPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 60
    Align = alClient
    BorderOuter = fsNone
    TabOrder = 0
    DesignSize = (
      400
      60)
    object Label4: TLabel
      Left = 11
      Top = 10
      Width = 77
      Height = 13
      Caption = 'Connection str. :'
      Transparent = True
    end
    object Label9: TLabel
      Left = 11
      Top = 37
      Width = 71
      Height = 13
      Caption = 'Conn. timeout :'
      Transparent = True
    end
    object Label2: TLabel
      Left = 229
      Top = 37
      Width = 90
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Command timeout :'
      Transparent = True
    end
    object edLocalDBName: TRzDBEdit
      Tag = -1
      Left = 92
      Top = 6
      Width = 305
      Height = 21
      DataField = 'DBName'
      Anchors = [akLeft, akTop, akRight]
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 0
    end
    object edLocalCharset: TRzDBEdit
      Tag = 1
      Left = 92
      Top = 34
      Width = 69
      Height = 21
      DataField = 'Charset'
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 1
    end
    object RzDBEdit1: TRzDBEdit
      Tag = 1
      Left = 324
      Top = 34
      Width = 73
      Height = 21
      DataField = 'RoleName'
      Anchors = [akTop, akRight]
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 2
    end
  end
end
