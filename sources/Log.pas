unit Log;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzButton, RzTabs, ExtCtrls, RzPanel, StdCtrls, RzLabel,
  fConfServer;

type
  TfmLog = class(TForm)
    pnlButtons: TRzPanel;
    btnClose: TRzBitBtn;
    pnlInfos: TRzPanel;
    lblAliasName: TRzLabel;
    lblStatus: TRzLabel;
    lblAliasNameValue: TRzLabel;
    lblStatusValue: TRzLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmLog: TfmLog;

implementation

{$R *.dfm}

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
