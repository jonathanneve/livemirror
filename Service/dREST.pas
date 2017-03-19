unit dREST;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext, main,
  dLiveMirrorNode;

type
  TdmREST = class(TDataModule)
    HTTPServer: TIdHTTPServer;
    procedure HTTPServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    LiveMirror: TLiveMirror;
    function RunNow(configName: String): String;
  public
    procedure StartServer;
    procedure StopServer;
    constructor Create(lm: TLiveMirror);
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses LiveMirrorRunnerThread, uLkJSON, LMUtils;

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
  json: TlkJSONobject;
  cLogFileName: string;
  node: TdmLiveMirrorNode;
  th: TLiveMirrorRunnerThread;
  ss: TStringStream;
begin
  if ARequestInfo.CommandType = hcGET then begin
    if (ARequestInfo.Document = '/action/runnow') then
    begin
      cConfigName := ARequestInfo.Params.Values['config_name'];
      cLogFileName := RunNow(cConfigName);

      json := TlkJSONobject.Create;
      try
        json.Add('Result', 'OK');
        json.Add('LogFileName', ExtractFileName(cLogFileName));
        AResponseInfo.ContentText := TlkJSON.GenerateText(json);
      finally
        json.Free;
      end;
      AResponseInfo.ResponseNo := 200;
    end
    else if (ARequestInfo.Document = '/action/logfile') then
    begin
      cConfigName := ARequestInfo.Params.Values['config_name'];
      AResponseInfo.ServeFile(AContext, GetLiveMirrorRoot + '\Configs\' + cConfigName + '\log\'
        + ARequestInfo.Params.Values['log_file_name']);
    end
    else begin
      AResponseInfo.ResponseNo := 404;
    end;
  end
  else if ARequestInfo.CommandType = hcPOST then begin
    if (ARequestInfo.Document = '/action/replicate') then begin
      cConfigName := ARequestInfo.Params.Values['config_name'];
      ss := TStringStream.Create;
      try
        ss.CopyFrom(ARequestInfo.PostStream, ARequestInfo.ContentLength);
        json := TlkJSON.ParseText(ss.DataString) as TlkJsonObject;
      finally
        ss.Free;
      end;

      node := LiveMirror.GetNode(cConfigName, json);
      th := TLiveMirrorRunnerThread.Create(True);
      th.Node := node;
      th.Start;
      json.Free;

      json := TlkJSONobject.Create;
      try
        json.Add('Result', 'OK');
        //json.Add('LogFileName', ExtractFileName(cLogFileName));
        AResponseInfo.ContentText := TlkJSON.GenerateText(json);
      finally
        json.Free;
      end;
      AResponseInfo.ResponseNo := 200;
    end
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

function TdmREST.RunNow(configName: String): String;
var
  th: TLiveMirrorRunnerThread;
begin
  if not LiveMirror.IsThreadRunning(configName) then begin
    th := LiveMirror.StartThread(configName);
    if th <> nil then
      Result := th.Node.LogFileName;
  end;
end;

{
function TdmREST.ShowLog(configName: String): String;
begin

end;
 }

end.
