unit Main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, RzLabel, ExtCtrls, RzBckgnd, ActnList, Grids, Menus,
	DBGridEh, RzButton, RzPanel, RzDBGrid,
	LiveMirrorInterfaces, RzTray, DB, FIBDataSet, pFIBDataSet;

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
		dbgResults: TDBGridEh;
		mnuSettings: TMenuItem;
		mnuViewLog: TMenuItem;
		actViewLog: TAction;
    imgLogoMicrotec: TImage;
    qAliases: TpFIBDataSet;
    qAliasesDS: TDataSource;
    qAliasesALIAS_ID: TFIBIntegerField;
    qAliasesCONFIG_NAME: TFIBStringField;
    qAliasesDATE_SYNC: TFIBDateTimeField;
    qAliasesRECORDS_ERROR: TFIBIntegerField;
    qAliasesTRANSFER_STATUS: TFIBSmallIntField;
    qAliasesStatus: TStringField;
    RzButton2: TRzButton;
    RzButton1: TRzButton;
    TrayIcon: TRzTrayIcon;
		procedure actNewExecute(Sender: TObject);
		procedure btnCloseClick(Sender: TObject);
		procedure actViewLogExecute(Sender: TObject);
		procedure actEditExecute(Sender: TObject);
		procedure actDeleteExecute(Sender: TObject);
		procedure actRefreshConfigExecute(Sender: TObject);
		procedure actReplicateNowExecute(Sender: TObject);
		procedure popMainPopup(Sender: TObject);
    procedure imgLogoMicrotecClick(Sender: TObject);
    procedure dbgResultsDblClick(Sender: TObject);
    procedure qAliasesAfterScroll(DataSet: TDataSet);
    procedure qAliasesDATE_SYNCGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
    procedure qAliasesCalcFields(DataSet: TDataSet);
    procedure RzButton1Click(Sender: TObject);
    procedure RzButton2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private declarations }
		FISettingsModel: ISettingsModel;

		procedure DoEditSettings(const IsNew: boolean=false);
		procedure DoRefresh(Sender: TObject);
    procedure RefreshActions;
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
	ShellAPI;

{$R *.dfm}

constructor TfmMain.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
  qAliases.Open;
  RefreshActions;
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
	RemoveTriggers: boolean;
	MessageResult: integer;
begin
  if Application.MessageBox('Are you sure you want to delete this configuration?', 'Confirmation', MB_ICONWARNING + MB_YESNO + MB_DEFBUTTON2) = IDYES then begin
    MessageResult := MessageDlg('Remove triggers ?', mtConfirmation, [mbYes, mbNo], 0);
    RemoveTriggers := (MessageResult = mrYes);
    ErrorMessage := FISettingsModel.DoDeleteSettings(RemoveTriggers);
    if (ErrorMessage <> '') then
      MessageDlg(ErrorMessage, mtInformation, [mbOK], 0);
  end;
end;
//-----------------------------------------------------------------------------
procedure TfmMain.actRefreshConfigExecute(Sender: TObject);
var
	ErrorMessage: string;
begin
	ErrorMessage := FISettingsModel.DoRefreshSettings();
	if (ErrorMessage = '') then
		MessageDlg('Database replication configuration has been successfully updated.', mtInformation, [mbOK], 0)
	else // this case should never occur !!!!
		MessageDlg(ErrorMessage, mtError, [mbOK], 0);
end;
//-----------------------------------------------------------------------------
procedure TfmMain.actReplicateNowExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
  	FISettingsModel.DoReplicate();
    Application.MessageBox('Replication completed successfully!', 'Information', MB_ICONINFORMATION + MB_OK);
  finally
    Screen.Cursor := crDefault;
  end;
end;
//-----------------------------------------------------------------------------
procedure TfmMain.DoEditSettings(const IsNew: boolean);
begin
	with TfmSettings.Create(Self, IsNew, FISettingsModel) do try
		ShowModal();
  finally
    Free;
	end;
end;
//-----------------------------------------------------------------------------
procedure TfmMain.actViewLogExecute(Sender: TObject);
begin
  with TfmLog.Create(Self, FISettingsModel) do try
		ShowModal();
  finally
    Free;
	end;
end;
//-----------------------------------------------------------------------------
procedure TfmMain.btnCloseClick(Sender: TObject);
var
	MsgResult: integer;
begin
	MsgResult := MessageDlg('Do you really want to quit LiveMirror ?', mtConfirmation, mbOKCancel, 0);
	if (MsgResult = mrOK) then begin
		Application.Terminate();
	end;
end;
//-----------------------------------------------------------------------------
procedure TfmMain.DoRefresh(Sender: TObject);
begin
	qAliases.FullRefresh;
end;
//-----------------------------------------------------------------------------
procedure TfmMain.popMainPopup(Sender: TObject);
begin
  RefreshActions;
end;
//-----------------------------------------------------------------------------
procedure TfmMain.RefreshActions;
var
	IsMenuEnabled: boolean;
begin
	IsMenuEnabled := qAliases.RecordCount > 0;
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
	Value := ShellExecute(Self.Handle, 'open', 'http://www.microtec.fr/copycat/', nil, nil, SW_SHOWNORMAL);
	if (Value <= 32) then
		MessageDlg(SysErrorMessage(GetLastError), mtError, [mbOK], 0);
end;
//-----------------------------------------------------------------------------
procedure TfmMain.dbgResultsDblClick(Sender: TObject);
begin
  actViewLog.Execute;
end;

procedure TfmMain.qAliasesAfterScroll(DataSet: TDataSet);
begin
	dmLogsAndSettings.CcConfigStorage.Locate('ConfigName', qAliasesCONFIG_NAME.Value, []);
end;

procedure TfmMain.qAliasesDATE_SYNCGetText(Sender: TField;
  var Text: String; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := '-'
  else
    Text := Sender.AsString;
end;

procedure TfmMain.qAliasesCalcFields(DataSet: TDataSet);
begin
	if (qAliasesDATE_SYNC.IsNull) then begin
		qAliasesStatus.Value := ' - ';
	end
	else begin
		if (not qAliasesTRANSFER_STATUS.AsBoolean) then
			qAliasesStatus.Value := 'Running...'
		else if (qAliasesRECORDS_ERROR.Value = 0) then
      qAliasesStatus.Value := 'Completed successfully'
    else
			qAliasesStatus.Value := 'Completed with errors';
	end;
end;

procedure TfmMain.RzButton1Click(Sender: TObject);
begin
	if (MessageDlg('Do you really want to quit LiveMirror ?', mtConfirmation, mbOKCancel, 0) = mrOK) then
		Application.Terminate();
end;

procedure TfmMain.RzButton2Click(Sender: TObject);
begin
  TrayIcon.MinimizeApp;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TrayIcon.MinimizeApp;
  Action := caNone;
end;

end.
