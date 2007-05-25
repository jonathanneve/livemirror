object frConfInterbase: TfrConfInterbase
  Left = 0
  Top = 0
  Width = 400
  Height = 112
  TabOrder = 0
  object pnInterbase: TRzPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 112
    Align = alClient
    BorderOuter = fsNone
    TabOrder = 0
    Transparent = True
    DesignSize = (
      400
      112)
    object Label10: TLabel
      Left = 11
      Top = 89
      Width = 61
      Height = 13
      Caption = 'SQL dialect :'
      Transparent = True
    end
    object Label1: TLabel
      Left = 216
      Top = 90
      Width = 66
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Library name :'
      Transparent = True
    end
    object Label5: TLabel
      Left = 11
      Top = 36
      Width = 54
      Height = 13
      Caption = 'Username :'
      Transparent = True
    end
    object Label6: TLabel
      Left = 216
      Top = 36
      Width = 52
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Password :'
      Transparent = True
    end
    object Label4: TLabel
      Left = 11
      Top = 10
      Width = 76
      Height = 13
      Caption = 'Database path :'
      Transparent = True
    end
    object Label9: TLabel
      Left = 11
      Top = 63
      Width = 44
      Height = 13
      Caption = 'CharSet :'
      Transparent = True
    end
    object Label2: TLabel
      Left = 216
      Top = 63
      Width = 57
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Role name :'
      Transparent = True
    end
    object edLocalSQLDialect: TRzDBEdit
      Tag = 1
      Left = 92
      Top = 86
      Width = 73
      Height = 21
      DataField = 'SQLDialect'
      Alignment = taRightJustify
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 6
    end
    object RzDBEdit1: TRzDBEdit
      Tag = 1
      Left = 285
      Top = 86
      Width = 113
      Height = 21
      DataField = 'LibraryName'
      Anchors = [akTop, akRight]
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 7
    end
    object edLocalSYSDBAName: TRzDBEdit
      Tag = 1
      Left = 92
      Top = 33
      Width = 111
      Height = 21
      Hint = 'Name of the SYSDBA user of the local server'
      DataField = 'UserLogin'
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 2
    end
    object edLocalSYSDBAPassword: TRzDBEdit
      Tag = 1
      Left = 285
      Top = 33
      Width = 113
      Height = 21
      DataField = 'UserPassword'
      Anchors = [akTop, akRight]
      FrameController = dmLogsAndSettings.FrameController
      PasswordChar = '*'
      TabOrder = 3
    end
    object edDBName: TRzDBEdit
      Tag = -1
      Left = 92
      Top = 6
      Width = 282
      Height = 21
      DataField = 'DBName'
      Anchors = [akLeft, akTop, akRight]
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 0
    end
    object edLocalCharset: TRzDBEdit
      Tag = 1
      Left = 92
      Top = 60
      Width = 111
      Height = 21
      DataField = 'Charset'
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 4
    end
    object edRoleName: TRzDBEdit
      Tag = 1
      Left = 285
      Top = 60
      Width = 113
      Height = 21
      DataField = 'RoleName'
      Anchors = [akTop, akRight]
      FrameController = dmLogsAndSettings.FrameController
      TabOrder = 5
    end
    object btBrowseDB: TBitBtn
      Left = 375
      Top = 6
      Width = 22
      Height = 22
      Hint = 'Browse for database'
      Anchors = [akTop, akRight]
      TabOrder = 1
      OnClick = btBrowseDBClick
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000FF00FF00FF00
        FF00C4CCD000B9C1C500AFB6B900ADB4B700B6BDC000C2CACE00C6CED200C6CE
        D200FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00B9C0C4008C929500676B6D0064686A007C8183009EA4A800ABB2B600B3BA
        BE00BFC7CA00C5CDD100C6CED200FF00FF00FF00FF00FF00FF00FF00FF00C4CB
        CF007FA5B9000B6E9D0016719A00396C84004548490054575900606466007579
        7C00959B9E00A8AFB200B3BABE00C1C9CD00C6CED200FF00FF00FF00FF00BBC3
        C6002F93BC00007AAD004CD9F7000CA3D2000480B2001273A1002F6F8E004A56
        5B00505355005C606200757A7D009CA2A500B0B7BB00C1C9CD00C4CCD0006C9F
        B5001988B600007DB00090EFFF0030E0FF0029E2FF001DCBEE000FA4D2000482
        B4000C76A5002D6F9000434648005356580072777900B1B8BB00BDC4C8003D8F
        AF003B9FC600007FB2009FF1FF0046E2FF0040E1FF003AE0FF0034E0FF0033E2
        FF002DD0EE0020B1DD000C86B600136E9800585B5D00A9B0B3007CABBD001082
        B400B6F5FB000081B400B0F7FF005EECFF0058E9FF0052E7FF004BE4FF0045E2
        FF0045E0FF0046E2FF003FCFF000006DA00055595B00A8AFB2004B9BB90043A5
        C800DDFFFF000084B700C0FCFF0077F4FF0070F1FF006AEFFF0063ECFF005CEA
        FF0058E9FF0056E4FE0064DAED00006FA20055585A00A8AFB2002B93BB00ABDC
        EA00E5FFFF000086B900D1FFFF008EFDFF0089FAFF0082F6FF007AF4FF0073F3
        FF006CF0FF004CC9E300AAFFFF000072A50055585A00A8AFB2000B8DBC00CAF5
        FA00F1FFFF000088BB00DCFFFF00A1FFFF009CFBFF0094F9FF008CF7FF0085F6
        FF007EF5FF005DCBDF00D1FFFF000074A70055585A00A8AFB200048FC2000F92
        C1007EC4DD00008ABD00C3EDF5007ADBEA0085E3EF0092F0F8009CFAFF0094F8
        FF0065D2E700AAF4F900DAFFFF000077AA0055585A00A8AFB200FF00FF00C6CE
        D200C6CED200008DC000F2FFFF00C8F7FB00ABE7F10081D4E6006BC7DF0065C6
        DF005FC2DB00D3FFFF00E7FFFF000079AC0055585A00A8AFB200FF00FF00FF00
        FF00FF00FF001D99C90031A5CD004AB0D30083CDE200D0EFF600E6FCFC00F1FF
        FF00E6FFFF00DEFFFF00F3FFFF00007CAF0055595B00A8AFB200FF00FF00FF00
        FF00FF00FF00FF00FF00C6CED20097C1D20062ACC800379CC4002793BE00158E
        BE00FFFFFF00FFFFFF00FFFFFF00007EB1005C606200ABB1B500FF00FF00FF00
        FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00C6CED200078B
        BC00EDF6FA00FFFFFF00FFFFFF00007EB10080858700B6BDC000FF00FF00FF00
        FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0035A0
        CB000086B9000084B7000082B500488CAD00B5BCC000C3CBCF00}
    end
  end
  object OpenDialog: TRzOpenDialog
    FrameVisible = True
    HotTrack = True
    Title = 'Select database file'
    Filter = 'Interbase databases|*.gdb|FireBird databases|*.fdb|All files|*.*'
    DefaultExt = '.gdb'
    Left = 256
    Top = 8
  end
end
