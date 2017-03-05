unit dREST;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, main, IdContext;

type
  TdmREST = class(TDataModule)
    HTTPServer: TIdHTTPServer;
    procedure HTTPServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    LiveMirror: TLiveMirror;
  public
    procedure StartServer;
    procedure StopServer;
    constructor Create(lm: TLiveMirror);
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmREST }

constructor TdmREST.Create(lm: TLiveMirror);
begin
  inherited Create(nil);
  LiveMirror := lm;
end;

procedure TdmREST.HTTPServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  cConfigName: string;
begin
  if (ARequestInfo.Document = '/action/runnow') then
  begin
    cConfigName := ARequestInfo.Params.Values['config_name'];
    AResponseInfo.ContentText := cConfigName;
    AResponseInfo.ResponseNo := 200;
  end;
end;

procedure TdmREST.StartServer;
begin
  HTTPServer.Active := True;
end;

procedure TdmREST.StopServer;
begin
  HTTPServer.Active := False;
end;

end.
