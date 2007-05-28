unit fConfInterbase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzCmboBx, RzDBCmbo, Mask, RzEdit, RzDBEdit, CcInterbase,
  ExtCtrls, RzPanel, Buttons, RzShellDialogs;

type
  TfrConfInterbase = class(TFrame)
    pnInterbase: TRzPanel;
    Label10: TLabel;
    Label1: TLabel;
    edLocalSQLDialect: TRzDBEdit;
    RzDBEdit1: TRzDBEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label4: TLabel;
    Label9: TLabel;
    Label2: TLabel;
    edLocalSYSDBAName: TRzDBEdit;
    edLocalSYSDBAPassword: TRzDBEdit;
    edDBName: TRzDBEdit;
    edLocalCharset: TRzDBEdit;
    edRoleName: TRzDBEdit;
    btBrowseDB: TBitBtn;
    OpenDialog: TRzOpenDialog;
    procedure btBrowseDBClick(Sender: TObject);
  private
    { Private declarations }
  public
    function GetConnectorName: String;
  end;

implementation

uses 	StrUtils,
  dLogsAndSettings, CcProvUIB, CcProvFIBPlus;

{$R *.dfm}

procedure TfrConfInterbase.btBrowseDBClick(Sender: TObject);
var
  DBVersion: String;
begin
  DBVersion := edDBName.DataSource.DataSet.FieldByName('DBVersion').AsString;
	if (AnsiContainsStr(DBVersion, 'IB')) then
		OpenDialog.FilterIndex := 1
	else if (AnsiContainsStr(DBVersion, 'FB')) then
		OpenDialog.FilterIndex := 2
	else
		OpenDialog.FilterIndex := 3;

	if OpenDialog.Execute then begin
		edDBName.DataSource.DataSet.Edit;
		edDBName.Field.AsString := OpenDialog.FileName;
	end;
end;

function TfrConfInterbase.GetConnectorName: String;
begin
  Result := TCcConnectionFIB.ConnectorName;
end;

end.
