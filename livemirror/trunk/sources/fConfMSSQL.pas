unit fConfMSSQL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, RzCmboBx, RzDBCmbo, Mask, RzEdit, RzDBEdit, ExtCtrls,
  RzPanel, CcSQLServer, CcConnADO, DBCtrls;

type
  TfrConfMSSQL = class(TFrame)
    pnMSSQL: TRzPanel;
    Label4: TLabel;
    Label9: TLabel;
    Label2: TLabel;
    edLocalCharset: TRzDBEdit;
    RzDBEdit1: TRzDBEdit;
    RzDBMemo1: TRzDBMemo;
  private
    { Private declarations }
  public
    function GetConnectorName: String;
  end;

implementation

uses dLogsAndSettings;

{$R *.dfm}

function TfrConfMSSQL.GetConnectorName: String;
begin
  Result := TCcConnectionADO.ConnectorName;
end;

end.
