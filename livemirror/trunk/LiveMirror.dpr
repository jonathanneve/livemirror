program LiveMirror;

uses
  Forms,
  dLogsAndSettings in 'sources\dLogsAndSettings.pas' {dmLogsAndSettings: TDataModule},
  fConfInterbase in 'sources\fConfInterbase.pas' {frConfInterbase: TFrame},
  fConfMSSQL in 'sources\fConfMSSQL.pas' {frConfMSSQL: TFrame},
  fConfServer in 'sources\fConfServer.pas' {frConfServer: TFrame},
  Log in 'sources\Log.pas' {fmLog},
  Main in 'sources\Main.pas' {fmMain},
  Settings in 'sources\Settings.pas' {fmSettings},
  LiveMirrorInterfaces in 'sources\LiveMirrorInterfaces.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Microtec Live Mirror';
  Application.CreateForm(TdmLogsAndSettings, dmLogsAndSettings);
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
