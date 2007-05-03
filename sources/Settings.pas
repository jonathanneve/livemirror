unit Settings;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, RzButton, StdCtrls, RzLabel, RzPanel, ExtCtrls,
	fConfServer, LiveMirrorInterfaces, Mask, RzEdit, RzDBEdit, RzRadChk;

type
	TfmSettings = class(TForm, ISettingsView)
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
		frConfMaster: TfrConfServer;
		frConfMirror: TfrConfServer;
		edConfigName: TRzDBEdit;
		gbAutoReplication: TRzGroupBox;
		Label3: TLabel;
		edAutoReplicateFrequency: TRzDBEdit;
		cbAutoReplicate: TRzCheckBox;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure btnCloseClick(Sender: TObject);
		procedure btnSaveClick(Sender: TObject);
		procedure cbAutoReplicateClick(Sender: TObject);
	private
		{ Private declarations }
		FISettingsModel: ISettingsModel;
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

	if (IsNew) then begin
		FISettingsModel.Append();
		cbAutoReplicate.Checked := false;
		edAutoReplicateFrequency.Text := '0';
	end
	else begin
		FISettingsModel.EditSettings(FISettingsModel.SelectedConfigID);
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
	Action := caFree;
	fmSettings := nil;
end;
//-----------------------------------------------------------------------------

procedure TfmSettings.btnCloseClick(Sender: TObject);
begin
	FISettingsModel.DoCancelSettings();
	Self.Close();
end;
//-----------------------------------------------------------------------------

procedure TfmSettings.btnSaveClick(Sender: TObject);
var
	ErrorMessage: string;
begin
	ErrorMessage := FISettingsModel.DoSaveSettings();
	if (ErrorMessage = '') then
		Self.Close()
	else
		MessageDlg(ErrorMessage, mtError, [mbOK], 0);
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
