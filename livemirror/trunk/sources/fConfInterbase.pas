unit fConfInterbase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, RzCmboBx, RzDBCmbo, Mask, RzEdit, RzDBEdit, CcInterbase,
  ExtCtrls, RzPanel, CcProvFIBPlus;

type
  TfrConfInterbase = class(TFrame)
    pnInterbase: TRzPanel;
    Label10: TLabel;
    Label1: TLabel;
    edLocalSQLDialect: TRzDBEdit;
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
