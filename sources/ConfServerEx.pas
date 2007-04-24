unit ConfServerEx;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, fConfServer, DB, CcMemDS, RzShellDialogs, fConfInterbase,
  fConfMSSQL, StdCtrls, RzCmboBx, RzDBCmbo, Mask, RzEdit, RzDBEdit,
  DBCtrls, Buttons, ExtCtrls, RzPanel;

type
  TfrConfServerEx = class(TfrConfServer)
    cbDatabaseType: TRzDBComboBox;
    procedure cbDatabaseTypeChange(Sender: TObject);
  private
    { Private declarations }
  public
		{ Public declarations }
	end;

var
	frConfServerEx: TfrConfServerEx;

implementation

uses
	dLogsAndSettings;

{$R *.dfm}

procedure TfrConfServerEx.cbDatabaseTypeChange(Sender: TObject);
var
	IsEnabled: boolean;
	cConnectorType: string;
begin
	inherited;
	IsEnabled := cbDatabaseType.Text <> '';

	edVersions.Enabled := IsEnabled;
	edLocalDBName.Enabled := IsEnabled;
	edLocalSYSDBAName.Enabled := IsEnabled;
	edLocalSYSDBAPassword.Enabled := IsEnabled;
	edLocalCharset.Enabled := IsEnabled;
	edRoleName.Enabled := IsEnabled;

	if (IsEnabled) then begin
		if (cbDatabaseType.Text = 'MSSQL') then
			cConnectorType := 'ADO'
		else if (cbDatabaseType.Text = 'Interbase') then
			cConnectorType := 'FIB';

		dmLogsAndSettings.CcConfigStorage.Edit;
		dmLogsAndSettings.CcConfigStorage.LocalDB.DBType := cbDatabaseType.Text;
		dmLogsAndSettings.CcConfigStorage.LocalDB.ConnectorName := cConnectorType;
		LoadParams(dmLogsAndSettings.CcConfigStorage.LocalDB);
	end
	else begin
		Application.MessageBox('You must indicate which type of database you wish to connect to!', 'Missing information!', MB_ICONERROR + MB_OK);
	end;
end;
//-----------------------------------------------------------------------------

end.
