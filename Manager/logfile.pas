unit logfile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfmLogFile = class(TForm)
    memLog: TMemo;
    FileRefreshTimer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FileRefreshTimerTimer(Sender: TObject);
  private
    cFileName : String;
  public
    procedure LoadFile(cLogFileName: String);
    class procedure ShowLogFile(cLogFileName: String);
  end;

implementation

{$R *.dfm}

{ TfmLogFile }

procedure TfmLogFile.FileRefreshTimerTimer(Sender: TObject);
begin
  LoadFile(cFileName);
  memLog.SetFocus;
end;

procedure TfmLogFile.FormShow(Sender: TObject);
begin
  FileRefreshTimer.Enabled := True;
  ActiveControl := memLog;
end;

procedure TfmLogFile.LoadFile(cLogFileName: String);
var
  slLines :TStringList;
  Stream: TStream;
  I: Integer;
begin
  cFileName := cLogFileName;
  Caption := ExtractFileName(cLogFileName);
  Stream := TFileStream.Create(cLogFileName, fmOpenRead or fmShareDenyNone);
  slLines := TStringList.Create;
  try
    slLines.LoadFromStream(Stream);
    if slLines.Count > memLog.Lines.Count then begin
      for I := memLog.Lines.Count to slLines.Count-1 do
        memLog.Lines.Add(slLines[I]);

      memLog.SelStart := memLog.GetTextLen;
      memLog.SelLength := 0;
      memLog.ScrollBy(0, memLog.Lines.Count);
      memLog.Refresh;
    end;
  finally
    Stream.Free;
    slLines.Free;
  end;
end;

class procedure TfmLogFile.ShowLogFile(cLogFileName: String);
var
  fmLogFile: TfmLogFile;
begin
  fmLogFile := TfmLogFile.Create(Application);
  try
    fmLogFile.LoadFile(cLogFileName);
    fmLogFile.ShowModal;
  finally
    fmLogFile.Free;
  end;
end;

end.
