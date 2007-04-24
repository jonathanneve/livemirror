unit Main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, RzLabel, ExtCtrls, RzBckgnd, ActnList, Grids, DBGrids,
	RzDBGrid, Menus, DBGridEh, RzButton, RzPanel;

type
	TfmMain = class(TForm)
		RzLabel2: TRzLabel;
		Image1: TImage;
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
		procedure actNewExecute(Sender: TObject);
		procedure btnCloseClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
    procedure actViewLogExecute(Sender: TObject);
	private
		procedure DoRefresh(Sender: TObject);
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	fmMain: TfmMain;

implementation

uses
	dLogsAndSettings,
	Log,
	Settings;

const
	CONFIG_FILENAME = 'config.ini';

{$R *.dfm}

procedure TfmMain.actNewExecute(Sender: TObject);
begin
	if (not Assigned(fmSettings)) then begin
		fmSettings := TfmSettings.Create(Self);
		fmSettings.ShowModal();
	end
	else begin
		fmSettings.BringToFront();
	end;
end;
//-----------------------------------------------------------------------------

procedure TfmMain.actViewLogExecute(Sender: TObject);
begin
	if (not Assigned(fmLog)) then begin
		fmLog := TfmLog.Create(Self);
		fmLog.ShowModal();
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

procedure TfmMain.FormCreate(Sender: TObject);
begin
	// initialize application
	dmLogsAndSettings.CcConfigStorage.Path := ExtractFilePath(Application.ExeName) + CONFIG_FILENAME;
	dmLogsAndSettings.OnEndSync := DoRefresh;
end;
//-----------------------------------------------------------------------------

procedure TfmMain.DoRefresh(Sender: TObject);
begin
	//Rafraîchir la requête
end;
//-----------------------------------------------------------------------------

end.
