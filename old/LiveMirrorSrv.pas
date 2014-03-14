unit LiveMirrorSrv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type
  TService7 = class(TService)
  private
    { D�clarations priv�es }
  public
    function GetServiceController: TServiceController; override;
    { D�clarations publiques }
  end;

var
  Service7: TService7;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  Service7.Controller(CtrlCode);
end;

function TService7.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

end.
