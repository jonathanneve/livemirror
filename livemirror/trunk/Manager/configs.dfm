object fmConfigs: TfmConfigs
  Left = 0
  Top = 0
  Caption = 'LiveMirror Manager'
  ClientHeight = 477
  ClientWidth = 478
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 50
    Width = 478
    Height = 398
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    DesignSize = (
      478
      398)
    object GroupBox: TGroupBox
      Left = 11
      Top = -1
      Width = 462
      Height = 393
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Configurations'
      TabOrder = 0
      DesignSize = (
        462
        393)
      object listConfigs: TListBox
        Left = 3
        Top = 18
        Width = 367
        Height = 372
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 0
        OnDblClick = listConfigsDblClick
      end
      object btAdd: TBitBtn
        Left = 376
        Top = 18
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Add'
        TabOrder = 1
        OnClick = btAddClick
      end
      object btDelete: TBitBtn
        Left = 376
        Top = 70
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Delete'
        DoubleBuffered = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = btDeleteClick
      end
      object btProperties: TBitBtn
        Left = 376
        Top = 44
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Properties'
        DoubleBuffered = False
        TabOrder = 3
        OnClick = btPropertiesClick
      end
      object btLog: TBitBtn
        Left = 376
        Top = 122
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Log'
        DoubleBuffered = False
        TabOrder = 4
        OnClick = btLogClick
      end
      object btRun: TBitBtn
        Left = 376
        Top = 96
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Run now'
        DoubleBuffered = False
        TabOrder = 5
        OnClick = btRunClick
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 478
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      478
      50)
    object Label1: TLabel
      Left = 11
      Top = 30
      Width = 104
      Height = 13
      Caption = 'LiveMirror service is  :'
    end
    object lbServiceStatus: TLabel
      Left = 144
      Top = 30
      Width = 67
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'RUNNING'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = [seClient, seBorder]
    end
    object Label2: TLabel
      Left = 11
      Top = 8
      Width = 112
      Height = 13
      Caption = 'CopyCat LiverMirror  v.'
    end
    object lbVersion: TLabel
      Left = 125
      Top = 8
      Width = 34
      Height = 13
      Caption = 'X.XX.X'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btServiceStopStart: TButton
      Left = 387
      Top = 25
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Stop'
      TabOrder = 0
      OnClick = btServiceStopStartClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 448
    Width = 478
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Button1: TButton
      Left = 11
      Top = 0
      Width = 148
      Height = 25
      Caption = 'Error management options'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object ServiceRefreshTimer: TTimer
    Enabled = False
    OnTimer = ServiceRefreshTimerTimer
    Left = 248
    Top = 16
  end
end
