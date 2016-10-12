object fmConfig: TfmConfig
  Left = 0
  Top = 0
  Caption = 'Setup backup configuration'
  ClientHeight = 274
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    433
    274)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 101
    Height = 13
    Caption = 'Configuration name :'
  end
  object edFrenquency: TLabeledEdit
    Left = 269
    Top = 24
    Width = 156
    Height = 21
    Anchors = [akTop, akRight]
    EditLabel.Width = 102
    EditLabel.Height = 13
    EditLabel.Caption = 'Sync frequency (sec)'
    NumbersOnly = True
    TabOrder = 1
    Text = '30'
    OnChange = edFrenquencyChange
  end
  object PageControl: TPageControl
    Left = 8
    Top = 51
    Width = 418
    Height = 187
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object tsMaster: TTabSheet
      Caption = 'Master database'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 410
        Height = 33
        Align = alTop
        TabOrder = 0
        object Label2: TLabel
          Left = 8
          Top = 8
          Width = 71
          Height = 13
          Caption = 'Database type'
        end
        object cbMasterDBType: TComboBox
          Left = 85
          Top = 5
          Width = 164
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbMasterDBTypeChange
          Items.Strings = (
            'Firebird'
            'Microsoft SQL Server'
            'SQLite')
        end
      end
    end
    object tsMirror: TTabSheet
      Caption = 'Mirror database'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 410
        Height = 33
        Align = alTop
        TabOrder = 0
        object Label3: TLabel
          Left = 8
          Top = 8
          Width = 71
          Height = 13
          Caption = 'Database type'
        end
        object cbMirrorDBType: TComboBox
          Left = 85
          Top = 5
          Width = 164
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbMirrorDBTypeChange
          Items.Strings = (
            'Firebird'
            'Microsoft SQL Server'
            'SQLite')
        end
      end
    end
    object Options: TTabSheet
      Caption = 'Options'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lbSelectExcludedTables: TLabel
        Left = 257
        Top = 34
        Width = 73
        Height = 13
        Cursor = crHandPoint
        Caption = 'Select tables'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold, fsUnderline]
        ParentFont = False
        OnClick = lbSelectExcludedTablesClick
      end
      object lbMetaDataStatus: TLabel
        Left = 10
        Top = 111
        Width = 295
        Height = 13
        Caption = 'LiveMirror meta-data has been CREATED in master database.'
      end
      object lbAddRemoveMetaData: TLabel
        Left = 10
        Top = 130
        Width = 111
        Height = 13
        Cursor = crHandPoint
        Caption = 'Remove meta-data'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold, fsUnderline]
        ParentFont = False
        OnClick = lbAddRemoveMetaDataClick
      end
      object rbAllTables: TRadioButton
        Left = 10
        Top = 10
        Width = 213
        Height = 17
        Caption = 'Synchronize all tables'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbAllTablesClick
      end
      object rbExcludeSelectedTables: TRadioButton
        Left = 10
        Top = 33
        Width = 241
        Height = 17
        Caption = 'Synchronize all except selected tables'
        TabOrder = 1
        OnClick = rbAllTablesClick
      end
      object cbTrackChanges: TCheckBox
        Left = 10
        Top = 70
        Width = 322
        Height = 17
        Caption = 'Replicate only changed fields'
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 2
        Visible = False
        OnClick = cbTrackChangesClick
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Error options'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        410
        159)
      object cbDefaultErrorReporting: TRadioButton
        Left = 24
        Top = 48
        Width = 353
        Height = 17
        Caption = 'Use default error reporting options'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = cbDefaultErrorReportingClick
      end
      object cbCustomErrorManagement: TRadioButton
        Left = 24
        Top = 84
        Width = 241
        Height = 17
        Caption = 'Customize error reporting:'
        TabOrder = 1
        OnClick = cbCustomErrorManagementClick
      end
      object btErrorConfig: TButton
        Left = 304
        Top = 84
        Width = 103
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Configure...'
        Enabled = False
        TabOrder = 2
        OnClick = btErrorConfigClick
      end
    end
  end
  object Button3: TButton
    Left = 350
    Top = 241
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object Button4: TButton
    Left = 269
    Top = 241
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 4
  end
  object edConfigName: TMaskEdit
    Left = 8
    Top = 24
    Width = 127
    Height = 21
    EditMask = '>aaaaaaaaaaaaa;0; '
    MaxLength = 13
    TabOrder = 0
    Text = ''
    OnChange = edConfigNameChange
  end
  object btLicensing: TButton
    Left = 8
    Top = 241
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Licensing'
    TabOrder = 5
    OnClick = btLicensingClick
  end
  object CcConfig: TCcConfig
    TrackFieldChanges = False
    FailIfNoPK = False
    Tables = <>
    Version = '3.9.2'
    Left = 156
    Top = 6
  end
end
