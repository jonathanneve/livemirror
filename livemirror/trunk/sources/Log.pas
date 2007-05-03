unit Log;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, RzButton, RzTabs, ExtCtrls, RzPanel, StdCtrls, RzLabel,
	fConfServer, Grids, DBGridEh, LiveMirrorInterfaces, RzSplit, dLogsAndSettings,
	Mask, RzEdit, RzDBEdit, DBCtrls;

type
	TfmLog = class(TForm)
		pnlButtons: TRzPanel;
		btnClose: TRzBitBtn;
		pnlInfos: TRzPanel;
		lblAliasName: TRzLabel;
		dbgLog: TDBGridEh;
		txtAlias: TDBText;
		RzSizePanel1: TRzSizePanel;
		dbgLogErrors: TDBGridEh;
		lblErrorsDetails: TLabel;
		procedure btnCloseClick(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private declarations }
		FISettingsModel: ISettingsModel;
	public
		{ Public declarations }
		constructor Create(AOwner: TComponent; AISettingsModel: ISettingsModel); reintroduce; virtual;
		destructor Destroy(); override;
	end;

var
  fmLog: TfmLog;

implementation

{$R *.dfm}

constructor TfmLog.Create(AOwner: TComponent; AISettingsModel: ISettingsModel);
begin
	inherited Create(AOwner);
	FISettingsModel := AISettingsModel;
	FISettingsModel.DoViewLog();
end;
//-----------------------------------------------------------------------------

destructor TfmLog.Destroy();
begin
	FISettingsModel := nil;
	inherited Destroy();
end;
//-----------------------------------------------------------------------------

procedure TfmLog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	Action := caFree;
	fmLog := nil;
end;
//-----------------------------------------------------------------------------

procedure TfmLog.btnCloseClick(Sender: TObject);
begin
	Self.Close();
end;
//-----------------------------------------------------------------------------

end.
