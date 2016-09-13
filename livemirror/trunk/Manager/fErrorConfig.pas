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
    procedure UpdateConfig;
  public
    procedure Init(conf: TCcErrorConfig);
    destructor Destroy;override;
  end;

implementation

{$R *.dfm}

{ TfrErrorConfig }

destructor TfrErrorConfig.Destroy;
begin
  UpdateConfig;
  inherited;
end;

procedure TfrErrorConfig.edTryAgainSecondsExit(Sender: TObject);
begin
  UpdateConfig;
end;

procedure TfrErrorConfig.UpdateConfig;
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
