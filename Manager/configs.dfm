object fmConfigs: TfmConfigs
  Left = 0
  Top = 0
  Caption = 'LiveMirror Manager'
  ClientHeight = 213
  ClientWidth = 311
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
    Width = 311
    Height = 134
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    DesignSize = (
      311
      134)
    object GroupBox: TGroupBox
      Left = 6
      Top = 0
      Width = 295
      Height = 129
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Configurations'
      TabOrder = 0
      DesignSize = (
        295
        129)
      object listConfigs: TListBox
        Left = 3
        Top = 18
        Width = 200
        Height = 108
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 0
        OnDblClick = listConfigsDblClick
      end
      object btAdd: TBitBtn
        Left = 210
        Top = 18
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Add'
        TabOrder = 1
        OnClick = btAddClick
      end
      object btDelete: TBitBtn
        Left = 210
        Top = 80
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Delete'
        DoubleBuffered = False
        TabOrder = 2
        OnClick = btDeleteClick
      end
      object btProperties: TBitBtn
        Left = 210
        Top = 49
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Properties'
        DoubleBuffered = False
        TabOrder = 3
        OnClick = btPropertiesClick
      end
    end
  end
  object pnEvaluation: TPanel
    Left = 0
    Top = 184
    Width = 311
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object lbEvaluation: TLabel
      Left = 6
      Top = 0
      Width = 295
      Height = 23
      Alignment = taCenter
      AutoSize = False
      Caption = 'EVALUATION VERSION'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 311
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      311
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
    end
    object Label2: TLabel
      Left = 11
      Top = 8
      Width = 110
      Height = 13
      Caption = 'Microtec LiverMirror  v.'
    end
    object lbVersion: TLabel
      Left = 125
      Top = 8
      Width = 34
      Height = 13
      Caption = '1.00.0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btServiceStopStart: TButton
      Left = 220
      Top = 25
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Stop'
      TabOrder = 0
      OnClick = btServiceStopStartClick
    end
  end
  object PipeServer: TPipeServer
    Active = False
    OnPipeConnect = PipeServerPipeConnect
    PipeName = 'LiveMirrorMgrPipeServer'
    Left = 144
    Top = 120
  end
  object PipeClient: TPipeClient
    MemoryThrottle = 10240000
    PipeName = 'LiveMirrorMgrPipeServer'
    Left = 160
    Top = 64
  end
  object ServiceRefreshTimer: TTimer
    Enabled = False
    OnTimer = ServiceRefreshTimerTimer
    Left = 104
    Top = 120
  end
end
