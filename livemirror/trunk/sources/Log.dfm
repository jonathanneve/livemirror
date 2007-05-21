object fmLog: TfmLog
  Left = 276
  Top = 169
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
    object txtAlias: TDBText
      Left = 88
      Top = 8
      Width = 576
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      DataField = 'CONFIG_NAME'
      DataSource = dmLogsAndSettings.dtsSelectLogDS
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
    Height = 374
    Align = alClient
    AutoFitColWidths = True
    DataSource = dmLogsAndSettings.dtsSelectLogDS
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
        EditButtons = <>
        FieldName = 'LOG_ID'
        Footers = <>
        Visible = False
      end
      item
        EditButtons = <>
        FieldName = 'TRANSFER_STATUS'
        Footers = <>
        Visible = False
      end
      item
        Alignment = taCenter
        EditButtons = <>
        FieldName = 'DATE_SYNC'
        Footers = <>
        Title.Alignment = taCenter
        Title.Caption = 'Last synchronization'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = []
        Width = 146
      end
      item
        Alignment = taCenter
        EditButtons = <>
        FieldName = 'RECORDS_OK'
        Footers = <>
        Title.Alignment = taCenter
        Title.Caption = 'Rows synchronized'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = []
        Width = 123
      end
      item
        Alignment = taCenter
        EditButtons = <>
        FieldName = 'RECORDS_ERROR'
        Footers = <>
        Title.Alignment = taCenter
        Title.Caption = 'Errors count'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = []
        Width = 103
      end
      item
        Alignment = taCenter
        EditButtons = <>
        FieldName = 'CONVERTED_STATUS'
        Footers = <>
        Title.Alignment = taCenter
        Title.Caption = 'Status'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -11
        Title.Font.Name = 'MS Sans Serif'
        Title.Font.Style = []
        Width = 260
      end>
  end
  object RzSizePanel1: TRzSizePanel
    Left = 0
    Top = 407
    Width = 671
    Height = 8
    Align = alBottom
    HotSpotVisible = True
    SizeBarWidth = 7
    TabOrder = 3
    HotSpotClosed = True
    HotSpotPosition = 130
    object lblErrorsDetails: TLabel
      Left = 0
      Top = 8
      Width = 671
      Height = 25
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Errors details'
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
      DataSource = dmLogsAndSettings.dtsSelectLogErrorsDS
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
end
