unit metadata;

interface

uses
  System.SysUtils, System.Classes, CcConfStorage, CcConf, CcProviders;

type
  TdmMetaData = class(TDataModule)
    MasterConfig: TCcConfig;
    MirrorConfig: TCcConfig;
  private
    FMasterConnection: TCcConnection;
    FMirrorConnection: TCcConnection;
    function ConfigDatabases: Boolean;
    { Private declarations }
  public
    property MasterConnection : TCcConnection read FMasterConnection write FMasterConnection;
    property MirrorConnection : TCcConnection read FMirrorConnection write FMirrorConnection;
    function ConfigureMaster: Boolean;
    function ConfigureMirror: Boolean;
    function RemoveConfigurationFromMaster: Boolean;
    function RemoveConfigurationFromMirror: Boolean;
  end;

var
  dmMetaData: TdmMetaData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


end.
