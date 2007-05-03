unit fConfMSSQL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, RzCmboBx, RzDBCmbo, Mask, RzEdit, RzDBEdit, ExtCtrls,
  RzPanel, CcSQLServer, CcConnADO;

type
  TfrConfMSSQL = class(TFrame)
    pnMSSQL: TRzPanel;
    Label4: TLabel;
    Label9: TLabel;
    Label2: TLabel;
    edLocalDBName: TRzDBEdit;
    edLocalCharset: TRzDBEdit;
    RzDBEdit1: TRzDBEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses dLogsAndSettings;

{$R *.dfm}

end.
