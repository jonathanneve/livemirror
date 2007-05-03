unit Main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, RzLabel, ExtCtrls, RzBckgnd, ActnList, Grids, Menus,
	DBGridEh, RzButton, RzPanel, RzDBGrid,
	LiveMirrorInterfaces, RzTray;

type
	TfmMain = class(TForm)
		RzLabel2: TRzLabel;
    imgLogoMain: TImage;
		RzBackground1: TRzBackground;
		RzLabel1: TRzLabel;
		ActionList: TActionList;
		actNew: TAction;
		actEdit: TAction;
		actDelete: TAction;
		actRefreshConfig: TAction;
		actReplicateNow: TAction;
		popMain: TPopupMenu;
		mnuNew: TMenuItem;
		mnuDelete: TMenuItem;
		mnuEdit: TMenuItem;
		mnuRefreshConfig: TMenuItem;
		mnuReplicateNow: TMenuItem;
		pnlMain: TPanel;
		pnlButtons: TRzPanel;
		btnClose: TRzBitBtn;
		dbgResults: TDBGridEh;
		mnuSettings: TMenuItem;
		mnuViewLog: TMenuItem;
		actViewLog: TAction;
		RzTrayIcon: TRzTrayIcon;
    imgLogoMicrotec: TImage;
		procedure actNewExecute(Sender: TObject);
		procedure btnCloseClick(Sender: TObject);
		procedure actViewLogExecute(Sender: TObject);
		procedure actEditExecute(Sender: TObject);
		procedure actDeleteExecute(Sender: TObject);
		procedure actRefreshConfigExecute(Sender: TObject);
		procedure actReplicateNowExecute(Sender: TObject);
		procedure popMainPopup(Sender: TObject);
    procedure imgLogoMicrotecClick(Sender: TObject);
	private
		{ Private declarations }
		FISettingsModel: ISettingsModel;

		procedure DoEditSettings(const IsNew: boolean=false);
		procedure DoRefresh(Sender: TObject);
//		procedure DoRefreshMainView(Sender: TObject);
//		procedure DoRefreshLog(const ConfigID: integer);
//		procedure DoRefreshLogErrors(const ConfigID: integer);
	public
		{ Public declarations }
		constructor Create(AOwner: TComponent); override;
		destructor Destroy(); override;
	end;

var
	fmMain: TfmMain;

implementation

uses
	dLogsAndSettings,
	Log,
	Settings,
	DB,
	ShellAPI;

{$R *.dfm}

constructor TfmMain.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
//	FISettingsModel := TdmLogsAndSettings.Create(Self);		// do not forgot delete auto datamodule construction and comment above code line ==> raise exception on OnChange event on fConfServer frame
	FISettingsModel := dmLogsAndSettings as ISettingsModel;
	FISettingsModel.OnEndSync := DoRefresh;
	actEdit.Enabled := false;
end;
//-----------------------------------------------------------------------------

destructor TfmMain.Destroy();
begin
	FISettingsModel := nil;
	inherited Destroy();
end;
//-----------------------------------------------------------------------------

procedure TfmMain.actNewExecute(Sender: TObject);
begin
	DoEditSettings(true);
end;
//-----------------------------------------------------------------------------

procedure TfmMain.actEditExecute(Sender: TObject);
begin
	DoEditSettings();
end;
//-----------------------------------------------------------------------------

procedure TfmMain.actDeleteExecute(Sender: TObject);
var
	ErrorMessage: string;
	IsRemoveTriggers: boolean;
	MessageResult: integer;
begin
	MessageResult := MessageDlg('Remove triggers ?', mtConfirmation, [mbYes, mbNo], 0);
	IsRemoveTriggers := (MessageResult = mrYes);
	ErrorMessage := FISettingsModel.DoDeleteSettings(IsRemoveTriggers);
	if (ErrorMessage <> '') then
		MessageDlg(ErrorMessage, mtInformation, [mbOK], 0);
end;
//-----------------------------------------------------------------------------

procedure TfmMain.actRefreshConfigExecute(Sender: TObject);
var
	ErrorMessage: string;
begin
	ErrorMessage := FISettingsModel.DoRefreshSettings();
	if (ErrorMessage = '') then
	begin
		MessageDlg('Refreshment of the data was made successfully.', mtInformation, [mbOK], 0);
	end
	else begin		// this case should never occured !!!!
		MessageDlg(ErrorMessage, mtError, [mbOK], 0);
	end;
end;
//-----------------------------------------------------------------------------

procedure TfmMain.actReplicateNowExecute(Sender: TObject);
begin
	FISettingsModel.DoReplicate();
end;
//-----------------------------------------------------------------------------

procedure TfmMain.DoEditSettings(const IsNew: boolean);
begin
	if (not Assigned(fmSettings)) then begin
		fmSettings := TfmSettings.Create(Self, IsNew, FISettingsModel);
		fmSettings.Show();
	end
	else begin
		fmSettings.BringToFront();
	end;
end;
//-----------------------------------------------------------------------------

procedure TfmMain.actViewLogExecute(Sender: TObject);
begin
	if (not Assigned(fmLog)) then begin
		fmLog := TfmLog.Create(Self, FISettingsModel);
		fmLog.Show();
	end
	else begin
		fmLog.BringToFront();
	end;
end;
//-----------------------------------------------------------------------------

procedure TfmMain.btnCloseClick(Sender: TObject);
var
	MsgResult: integer;
begin
	MsgResult := MessageDlg('Do you really want to quit Live Mirror ?', mtConfirmation, mbOKCancel, 0);
	if (MsgResult = mrOK) then begin
		Application.Terminate();
	end;
end;
//-----------------------------------------------------------------------------

procedure TfmMain.DoRefresh(Sender: TObject);
begin
	dmLogsAndSettings.dtsSelectAliases.FullRefresh;
end;
//-----------------------------------------------------------------------------

procedure TfmMain.popMainPopup(Sender: TObject);
var
	IsMenuEnabled: boolean;
begin
	IsMenuEnabled := FISettingsModel.SelectedConfigID > 0;
	actEdit.Enabled := IsMenuEnabled;
	actDelete.Enabled := IsMenuEnabled;
	actRefreshConfig.Enabled := IsMenuEnabled;
	actReplicateNow.Enabled := IsMenuEnabled;
	actViewLog.Enabled := IsMenuEnabled;
end;
//-----------------------------------------------------------------------------

procedure TfmMain.imgLogoMicrotecClick(Sender: TObject);
var
	Value: cardinal;
begin
	Value := ShellExecute(Self.Handle, 'open', 'http://www.microtec.fr', nil, nil, SW_SHOWNORMAL);
	if (Value <= 32) then
		MessageDlg(SysErrorMessage(GetLastError), mtError, [mbOK], 0);
end;
//-----------------------------------------------------------------------------

end.
