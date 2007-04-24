unit Settings;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, RzButton, StdCtrls, RzLabel, RzPanel, fConfServer, ExtCtrls,
	ConfServerEx;

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
		frConfServerExMaster: TfrConfServerEx;
		frConfServerExMirror: TfrConfServerEx;
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure btnCloseClick(Sender: TObject);
		procedure frConfServerExMastercbDatabaseTypeChange(Sender: TObject);
		procedure frConfServerExMirrorcbDatabaseTypeChange(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	fmSettings: TfmSettings;

implementation

{$R *.dfm}

procedure TfmSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	Action := caFree;
	fmSettings := nil;
end;
//-----------------------------------------------------------------------------

procedure TfmSettings.btnCloseClick(Sender: TObject);
begin
	Self.Close();
end;
//-----------------------------------------------------------------------------

procedure TfmSettings.frConfServerExMastercbDatabaseTypeChange(Sender: TObject);
begin
	frConfServerExMaster.cbDatabaseTypeChange(Sender);
end;
//-----------------------------------------------------------------------------

procedure TfmSettings.frConfServerExMirrorcbDatabaseTypeChange(Sender: TObject);
begin
	frConfServerExMirror.cbDatabaseTypeChange(Sender);
end;
//-----------------------------------------------------------------------------

end.
