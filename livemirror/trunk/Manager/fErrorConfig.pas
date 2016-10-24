unit fErrorConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, errors;

type
  TfrErrorConfig = class(TFrame)
    lbErrorType: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edEmails: TEdit;
    cbCanContinue: TComboBox;
    cbTryNextCycle: TComboBox;
    edTryAgainSeconds: TEdit;
    procedure edTryAgainSecondsExit(Sender: TObject);
  private
    FErrorConfig: TCcErrorConfig;
  public
    procedure Init(conf: TCcErrorConfig);
    procedure SaveConfig;
  end;

implementation

{$R *.dfm}

{ TfrErrorConfig }

procedure TfrErrorConfig.edTryAgainSecondsExit(Sender: TObject);
begin
  SaveConfig;
end;

procedure TfrErrorConfig.SaveConfig;
begin
  FErrorConfig.TryAgainSeconds := StrToInt(edTryAgainSeconds.Text);
  FErrorConfig.CanContinueReplCycle  := (cbCanContinue.ItemIndex = 1);
  FErrorConfig.TryAgainNextCycle  := (cbTryNextCycle.ItemIndex = 1);
  FErrorConfig.ReportErrorToEmail := edEmails.Text;
end;

procedure TfrErrorConfig.Init(conf: TCcErrorConfig);
begin
  FErrorConfig := conf;
  lbErrorType.Caption := FErrorConfig.ErrorType;
  edTryAgainSeconds.Text := IntToStr(FErrorConfig.TryAgainSeconds);

  if FErrorConfig.CanContinueReplCycle then
    cbCanContinue.ItemIndex := 1
  else
    cbCanContinue.ItemIndex := 0;

  if FErrorConfig.TryAgainNextCycle then
    cbTryNextCycle.ItemIndex := 1
  else
    cbTryNextCycle.ItemIndex := 0;

  edEmails.Text := FErrorConfig.ReportErrorToEmail;
end;

end.
