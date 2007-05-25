unit Settings;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, RzButton, StdCtrls, RzLabel, RzPanel, ExtCtrls,
	fConfServer, LiveMirrorInterfaces, Mask, RzEdit, RzDBEdit, RzRadChk;

type
	TfmSettings = class(TForm)
		gbxLocalDB: TRzGroupBox;
		RzGroupBox1: TRzGroupBox;
		pnlInfos: TRzPanel;
		lblAliasName: TRzLabel;
		lblStatus: TRzLabel;
		lblAliasNameValue: TRzLabel;
		lblStatusValue: TRzLabel;
		pnlButtons: TRzPanel;
		btnClose: TRzBitBtn;
		btnSave: TRzBitBtn;
		edConfigName: TRzDBEdit;
		gbAutoReplication: TRzGroupBox;
		Label3: TLabel;
		edAutoReplicateFrequency: TRzDBEdit;
		cbAutoReplicate: TRzCheckBox;
    frConfMaster: TfrConfServer;
    frConfMirror: TfrConfServer;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure btnSaveClick(Sender: TObject);
		procedure cbAutoReplicateClick(Sender: TObject);
	private
		{ Private declarations }
		FISettingsModel: ISettingsModel;
    lNew: Boolean;
	public
		{ Public declarations }
		constructor Create(AOwner: TComponent; const IsNew: boolean; AISettingsModel: ISettingsModel); reintroduce; virtual;
		destructor Destroy(); override;
	end;

var
	fmSettings: TfmSettings;

implementation

uses
	CcConf,
	CcConfStorage,
	dLogsAndSettings;

{$R *.dfm}

constructor TfmSettings.Create(AOwner: TComponent; const IsNew: boolean; AISettingsModel: ISettingsModel);
begin
	inherited Create(AOwner);
	FISettingsModel := AISettingsModel;
  lNew := IsNew;

	if (IsNew) then begin
		dmLogsAndSettings.CcConfigStorage.Append();
		cbAutoReplicate.Checked := false;
		edAutoReplicateFrequency.Text := '0';
	end
	else begin
		FISettingsModel.StopCurrentAutoReplication;
		cbAutoReplicate.Checked := (dmLogsAndSettings.CcConfigStorage.FieldByName('AutoReplicateFrequency').AsInteger > 0);
	end;

	frConfMaster.LoadParams(FISettingsModel.LocalDB);
	frConfMirror.LoadParams(FISettingsModel.RemoteDB);
	gbAutoReplication.Enabled := cbAutoReplicate.Checked;
end;
//-----------------------------------------------------------------------------
destructor TfmSettings.Destroy();
begin
	FISettingsModel := nil;
	inherited Destroy();
end;
//-----------------------------------------------------------------------------
procedure TfmSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	FISettingsModel.DoCancelSettings();
  FISettingsModel.StartCurrentAutoReplication;
end;
//-----------------------------------------------------------------------------
procedure TfmSettings.btnSaveClick(Sender: TObject);
begin
  FISettingsModel.DoSaveSettings(lNew);
  ModalResult := mrOk;
end;
//-----------------------------------------------------------------------------
procedure TfmSettings.cbAutoReplicateClick(Sender: TObject);
begin
	if not cbAutoReplicate.Checked then begin
		dmLogsAndSettings.CcConfigStorage.Edit;
		dmLogsAndSettings.CcConfigStorage.FieldByName('AutoReplicateFrequency').AsInteger := 0;
	end;
	gbAutoReplication.Enabled := cbAutoReplicate.Checked;
end;
//-----------------------------------------------------------------------------

end.
