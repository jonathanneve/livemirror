object frConfServer: TfrConfServer
  Left = 0
  Top = 0
  Width = 405
  Height = 231
  HelpContext = 1140
  TabOrder = 0
  object pnConnectParams: TRzPanel
    Left = 0
    Top = 21
    Width = 405
    Height = 210
    Align = alClient
    BorderOuter = fsNone
    ParentColor = True
    TabOrder = 1
    inline frConfMSSQL: TfrConfMSSQL
      Left = 0
      Top = 0
      Width = 405
      Height = 98
      Align = alTop
      TabOrder = 0
      Visible = False
      inherited pnMSSQL: TRzPanel
        Width = 405
        Transparent = True
        DesignSize = (
          405
          98)
        inherited Label2: TLabel
          Left = 234
        end
        inherited edLocalCharset: TRzDBEdit
          DataSource = mDBParamsDS
          DataField = 'ConnectionTimeout'
        end
        inherited RzDBEdit1: TRzDBEdit
          Left = 329
          DataSource = mDBParamsDS
          DataField = 'CommandTimeout'
        end
        inherited RzDBMemo1: TRzDBMemo
          DataField = 'ConnectionString'
          DataSource = mDBParamsDS
        end
      end
    end
    inline frConfInterbase: TfrConfInterbase
      Left = 0
      Top = 98
      Width = 405
      Height = 112
      Align = alTop
      TabOrder = 1
      Visible = False
      inherited pnInterbase: TRzPanel
        Width = 405
        DesignSize = (
          405
          112)
        inherited edLocalSQLDialect: TRzDBEdit
          DataSource = mDBParamsDS
        end
        inherited RzDBEdit1: TRzDBEdit
          DataSource = mDBParamsDS
        end
        inherited edLocalSYSDBAName: TRzDBEdit
          DataSource = mDBParamsDS
        end
        inherited edLocalSYSDBAPassword: TRzDBEdit
          DataSource = mDBParamsDS
        end
        inherited edDBName: TRzDBEdit
          DataSource = mDBParamsDS
        end
        inherited edLocalCharset: TRzDBEdit
          DataSource = mDBParamsDS
        end
        inherited edRoleName: TRzDBEdit
          DataSource = mDBParamsDS
        end
      end
    end
  end
  object RzPanel1: TRzPanel
    Left = 0
    Top = 0
    Width = 405
    Height = 21
    Align = alTop
    AutoSize = True
    BorderOuter = fsNone
    TabOrder = 0
    DesignSize = (
      405
      21)
    object Label3: TLabel
      Left = 11
      Top = 4
      Width = 44
      Height = 13
      Caption = 'DB type :'
      Transparent = True
    end
    object Label1: TLabel
      Left = 252
      Top = 4
      Width = 41
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Version :'
      Transparent = True
    end
    object cbVersions: TRzDBComboBox
      Left = 298
      Top = 0
      Width = 103
      Height = 21
      DataField = 'DBVersion'
      DataSource = mDBParamsDS
      Style = csDropDownList
      Anchors = [akTop, akRight]
      Ctl3D = False
      Enabled = False
      FrameController = dmLogsAndSettings.FrameController
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 1
      OnChange = cbVersionsChange
      Items.Strings = (
        'MSSQL2000')
    end
    object cbDatabaseType: TRzDBComboBox
      Left = 92
      Top = 0
      Width = 154
      Height = 21
      DataField = 'DBType'
      DataSource = mDBParamsDS
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Ctl3D = False
      FrameController = dmLogsAndSettings.FrameController
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = cbDatabaseTypeChange
    end
  end
  object mDBParams: TCcMemoryData
    Left = 48
    Top = 40
    object mDBParamsDBType: TStringField
      FieldName = 'DBType'
      OnChange = mDBParamsDBTypeChange
      Size = 50
    end
    object mDBParamsDBName: TStringField
      FieldName = 'DBName'
      OnChange = mDBParamsDBChange
      Size = 100
    end
    object mDBParamsUserLogin: TStringField
      FieldName = 'UserLogin'
      OnChange = mDBParamsDBChange
      Size = 50
    end
    object mDBParamsUserPassword: TStringField
      FieldName = 'UserPassword'
      OnChange = mDBParamsDBChange
      Size = 50
    end
    object mDBParamsCharset: TStringField
      FieldName = 'Charset'
      OnChange = mDBParamsDBChange
      Size = 50
    end
    object mDBParamsRoleName: TStringField
      FieldName = 'RoleName'
      OnChange = mDBParamsDBChange
      Size = 50
    end
    object mDBParamsDBVersion: TStringField
      FieldName = 'DBVersion'
      OnChange = mDBParamsDBChange
      Size = 50
    end
    object mDBParamsLibraryName: TStringField
      FieldName = 'LibraryName'
      OnChange = mDBParamsDBChange
      Size = 50
    end
    object mDBParamsSQLDialect: TIntegerField
      FieldName = 'SQLDialect'
      OnChange = mDBParamsDBChange
    end
    object mDBParamsConnectionString: TStringField
      FieldName = 'ConnectionString'
      OnChange = mDBParamsDBChange
      Size = 250
    end
    object mDBParamsADOConnectionTimeout: TIntegerField
      FieldName = 'ConnectionTimeout'
      OnChange = mDBParamsDBChange
    end
    object mDBParamsADOQueryTimeout: TIntegerField
      FieldName = 'CommandTimeout'
      OnChange = mDBParamsDBChange
    end
  end
  object mDBParamsDS: TDataSource
    DataSet = mDBParams
    Left = 48
    Top = 72
  end
end
