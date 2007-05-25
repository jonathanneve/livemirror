object fmLog: TfmLog
  Left = 522
  Top = 168
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Log'
  ClientHeight = 452
  ClientWidth = 671
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TRzPanel
    Left = 0
    Top = 415
    Width = 671
    Height = 37
    Align = alBottom
    BorderOuter = fsFlatRounded
    TabOrder = 0
    DesignSize = (
      671
      37)
    object btnClose: TRzBitBtn
      Left = 556
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
    Width = 671
    Height = 33
    Align = alTop
    BorderOuter = fsFlatRounded
    TabOrder = 1
    DesignSize = (
      671
      33)
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
    object lbAlias: TLabel
      Left = 88
      Top = 8
      Width = 576
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object dbgLog: TDBGridEh
    Left = 0
    Top = 33
    Width = 671
    Height = 252
    Align = alClient
    AutoFitColWidths = True
    DataSource = qLogDS
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'MS Sans Serif'
    FooterFont.Style = []
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Alignment = taCenter
        EditButtons = <>
        FieldName = 'DATE_SYNC'
        Footers = <>
        Title.Alignment = taCenter
        Title.Caption = 'Last synchronization'
        Width = 146
      end
      item
        Alignment = taCenter
        EditButtons = <>
        FieldName = 'RECORDS_OK'
        Footers = <>
        Title.Alignment = taCenter
        Title.Caption = 'Rows synchronized'
        Width = 123
      end
      item
        Alignment = taCenter
        EditButtons = <>
        FieldName = 'RECORDS_ERROR'
        Footers = <>
        Title.Alignment = taCenter
        Title.Caption = 'Errors count'
        Width = 103
      end
      item
        Alignment = taCenter
        EditButtons = <>
        FieldName = 'Status'
        Footers = <>
        Title.Alignment = taCenter
        Width = 260
      end>
  end
  object pnErrors: TRzSizePanel
    Left = 0
    Top = 285
    Width = 671
    Height = 130
    Align = alBottom
    HotSpotVisible = True
    SizeBarWidth = 7
    TabOrder = 3
    object lblErrorsDetails: TLabel
      Left = 0
      Top = 8
      Width = 671
      Height = 25
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Error details'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object dbgLogErrors: TDBGridEh
      Left = 0
      Top = 33
      Width = 671
      Height = 97
      Align = alClient
      Anchors = [akTop, akRight]
      AutoFitColWidths = True
      ColumnDefValues.EndEllipsis = True
      ColumnDefValues.Title.Alignment = taCenter
      ColumnDefValues.Title.EndEllipsis = True
      DataSource = qLogErrorsDS
      FooterColor = clWindow
      FooterFont.Charset = DEFAULT_CHARSET
      FooterFont.Color = clWindowText
      FooterFont.Height = -11
      FooterFont.Name = 'MS Sans Serif'
      FooterFont.Style = []
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      OptionsEh = [dghFixed3D, dghResizeWholeRightPart, dghHighlightFocus, dghClearSelection, dghDialogFind]
      ReadOnly = True
      RowSizingAllowed = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      Columns = <
        item
          EditButtons = <>
          FieldName = 'TABLE_NAME'
          Footers = <>
          Title.Caption = 'Table name'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 150
        end
        item
          EditButtons = <>
          FieldName = 'PRIMARY_KEYS'
          Footers = <>
          Title.Caption = 'Primary keys'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 150
        end
        item
          EditButtons = <>
          FieldName = 'ERROR_MESSAGE'
          Footers = <>
          Visible = False
        end
        item
          EditButtons = <>
          FieldName = 'CONVERTED_MESSAGE'
          Footers = <>
          Title.Caption = 'Message'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'MS Sans Serif'
          Title.Font.Style = [fsBold]
          Width = 350
        end>
    end
  end
  object qLog: TpFIBDataSet
    SelectSQL.Strings = (
      'SELECT '#9'*'
      'FROM LOG l'
      'JOIN ALIASES a ON (a.CONFIG_name = L.CONFIG_name)'
      'WHERE (L.CONFIG_NAME = :config_name)'
      'ORDER BY L.DATE_SYNC DESC')
    OnCalcFields = qLogCalcFields
    Transaction = dmLogsAndSettings.trLog
    Database = dmLogsAndSettings.dbLog
    Left = 136
    Top = 96
    object qLogLOG_ID: TFIBIntegerField
      FieldName = 'LOG_ID'
    end
    object qLogDATE_SYNC: TFIBDateTimeField
      FieldName = 'DATE_SYNC'
      DisplayFormat = 'dd/mm/yy hh:nn:ss'
    end
    object qLogRECORDS_OK: TFIBIntegerField
      FieldName = 'RECORDS_OK'
    end
    object qLogRECORDS_ERROR: TFIBIntegerField
      FieldName = 'RECORDS_ERROR'
    end
    object qLogTRANSFER_STATUS: TFIBSmallIntField
      FieldName = 'TRANSFER_STATUS'
    end
    object qLogCONFIG_NAME: TFIBStringField
      FieldName = 'CONFIG_NAME'
      Size = 200
      EmptyStrToNull = True
    end
    object qLogALIAS_ID: TFIBIntegerField
      FieldName = 'ALIAS_ID'
    end
    object qLogCONFIG_NAME1: TFIBStringField
      FieldName = 'CONFIG_NAME1'
      Size = 200
      EmptyStrToNull = True
    end
    object qLogStatus: TStringField
      FieldKind = fkCalculated
      FieldName = 'Status'
      Size = 200
      Calculated = True
    end
  end
  object qLogDS: TDataSource
    DataSet = qLog
    OnDataChange = qLogDSDataChange
    Left = 168
    Top = 96
  end
  object qLogErrors: TpFIBDataSet
    SelectSQL.Strings = (
      'SELECT'#9'LOG_ERROR_ID,'
      #9'LOG_ID,'
      '     '#9'TABLE_NAME,'
      '     '#9'PRIMARY_KEYS,'
      '     '#9'ERROR_MESSAGE'
      'FROM LOG_ERRORS'
      'WHERE LOG_ERRORS.LOG_ID = :log_ID')
    Transaction = dmLogsAndSettings.trLog
    Database = dmLogsAndSettings.dbLog
    Left = 136
    Top = 128
    object qLogErrorsLOG_ERROR_ID: TFIBIntegerField
      FieldName = 'LOG_ERROR_ID'
    end
    object qLogErrorsLOG_ID: TFIBIntegerField
      FieldName = 'LOG_ID'
    end
    object qLogErrorsTABLE_NAME: TFIBStringField
      FieldName = 'TABLE_NAME'
      Size = 100
      EmptyStrToNull = True
    end
    object qLogErrorsPRIMARY_KEYS: TFIBStringField
      FieldName = 'PRIMARY_KEYS'
      Size = 500
      EmptyStrToNull = True
    end
    object qLogErrorsERROR_MESSAGE: TFIBMemoField
      FieldName = 'ERROR_MESSAGE'
      BlobType = ftMemo
      Size = 8
    end
  end
  object qLogErrorsDS: TDataSource
    DataSet = qLogErrors
    Left = 168
    Top = 128
  end
end
