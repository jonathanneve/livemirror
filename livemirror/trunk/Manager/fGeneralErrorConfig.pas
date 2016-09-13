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
    procedure edEmailsExit(Sender: TObject);
  private
    FErrorConfig: TCcErrorConfig;
    procedure UpdateConfig;
    { Private declarations }
  public
    procedure Init(conf: TCcErrorConfig);
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

procedure TfrGeneralErrorConfig.UpdateConfig;
begin
  FErrorConfig.ReportAgainMinutes := StrToInt(edReportAgainMin.Text);
  FErrorConfig.ReportWhenResolved  := cbReportWhenResolved.Checked;
  FErrorConfig.ReportErrorToEmail := edEmails.Text;
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
end;

destructor TfrGeneralErrorConfig.Destroy;
begin
  UpdateConfig;
  inherited;
end;

end.
