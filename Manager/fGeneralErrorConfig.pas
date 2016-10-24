unit fGeneralErrorConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, errors;

type
  TfrGeneralErrorConfig = class(TFrame)
    lbErrorType: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edEmails: TEdit;
    edReportAgainMin: TEdit;
    cbReportWhenResolved: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    edTryAgainSeconds: TEdit;
    cbTryNextCycle: TComboBox;
    Label6: TLabel;
    procedure edEmailsExit(Sender: TObject);
  private
    FErrorConfig: TCcErrorConfig;
    procedure UpdateConfig;
    { Private declarations }
  public
    procedure Init(conf: TCcErrorConfig);
  end;

implementation

{$R *.dfm}

procedure TfrGeneralErrorConfig.UpdateConfig;
begin
  FErrorConfig.ReportAgainMinutes := StrToInt(edReportAgainMin.Text);
  FErrorConfig.ReportWhenResolved  := cbReportWhenResolved.Checked;
  FErrorConfig.ReportErrorToEmail := edEmails.Text;
  FErrorConfig.TryAgainNextCycle  := (cbTryNextCycle.ItemIndex = 1);
  FErrorConfig.TryAgainSeconds := StrToInt(edTryAgainSeconds.Text);
end;

procedure TfrGeneralErrorConfig.edEmailsExit(Sender: TObject);
begin
  UpdateConfig;
end;

procedure TfrGeneralErrorConfig.Init(conf: TCcErrorConfig);
begin
  FErrorConfig := conf;
  lbErrorType.Caption := FErrorConfig.ErrorType;
  edReportAgainMin.Text := IntToStr(FErrorConfig.ReportAgainMinutes);
  cbReportWhenResolved.Checked := FErrorConfig.ReportWhenResolved;
  edEmails.Text := FErrorConfig.ReportErrorToEmail;
  edTryAgainSeconds.Text := IntToStr(FErrorConfig.TryAgainSeconds);

  if FErrorConfig.TryAgainNextCycle then
    cbTryNextCycle.ItemIndex := 1
  else
    cbTryNextCycle.ItemIndex := 0;
end;

end.
