inherited frConfServerEx: TfrConfServerEx
  inherited pnConnectParams: TRzPanel
    inherited Panel1: TRzPanel
      inherited DBText1: TDBText
        Left = 85
        Width = 60
        Visible = False
      end
      inherited edLocalSYSDBAName: TRzDBEdit
        Enabled = False
        TabOrder = 3
      end
      inherited edLocalSYSDBAPassword: TRzDBEdit
        Enabled = False
        TabOrder = 4
      end
      inherited edLocalDBName: TRzDBEdit
        Enabled = False
        TabOrder = 2
      end
      inherited edLocalCharset: TRzDBEdit
        Enabled = False
        TabOrder = 5
      end
      inherited edVersions: TRzDBComboBox
        Enabled = False
        TabOrder = 1
      end
      inherited edRoleName: TRzDBEdit
        Enabled = False
        TabOrder = 6
      end
      object cbDatabaseType: TRzDBComboBox
        Left = 92
        Top = 8
        Width = 149
        Height = 21
        DataField = 'DBName'
        DataSource = mDBParamsDS
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = False
        FrameController = dmLogsAndSettings.FrameController
        ItemHeight = 13
        ParentCtl3D = False
        TabOrder = 0
        OnChange = cbDatabaseTypeChange
        Items.Strings = (
          'MSSQL2000')
      end
    end
    inherited frConfMSSQL: TfrConfMSSQL
      Visible = False
      inherited pnMSSQL: TRzPanel
        inherited edLocalDBName: TRzDBEdit
          DataSource = mDBParamsDS
          FrameController = dmLogsAndSettings.FrameController
        end
        inherited edLocalCharset: TRzDBEdit
          DataSource = mDBParamsDS
          FrameController = dmLogsAndSettings.FrameController
        end
        inherited RzDBEdit1: TRzDBEdit
          DataSource = mDBParamsDS
          FrameController = dmLogsAndSettings.FrameController
        end
      end
    end
    inherited frConfInterbase: TfrConfInterbase
      Visible = False
      inherited pnInterbase: TRzPanel
        inherited edLocalSQLDialect: TRzDBEdit
          DataSource = mDBParamsDS
          FrameController = dmLogsAndSettings.FrameController
        end
        inherited RzDBEdit1: TRzDBEdit
          DataSource = mDBParamsDS
          FrameController = dmLogsAndSettings.FrameController
        end
      end
    end
  end
  inherited OpenDialog: TRzOpenDialog
    Left = 128
    Top = 176
  end
  inherited mDBParams: TCcMemoryData
    Left = 160
    Top = 176
  end
  inherited mDBParamsDS: TDataSource
    Left = 192
    Top = 176
  end
end
