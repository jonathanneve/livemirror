unit licensing;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TfmLicensing = class(TForm)
    edLicenceKey: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FConfigName: String;
    FLicence: String;
  public
    class function AskForLicence(cConfigName: String) : String;
    constructor Create(AOwner: TComponent; cConfigName: String);
  end;

implementation

{$R *.dfm}

uses LMUtils, gnugettext;

class function TfmLicensing.AskForLicence(cConfigName: String) : String;
var
  fmLicensing: TfmLicensing;
begin
  fmLicensing := TfmLicensing.Create(Application, cConfigName);
  try
    if fmLicensing.ShowModal = mrOk then
      Result := fmLicensing.FLicence;
  finally
    fmLicensing.Free;
  end;
end;

procedure TfmLicensing.Button2Click(Sender: TObject);
begin
  FLicence := Trim(edLicenceKey.Text);
  if FLicence = '' then
    raise Exception.Create(_('You must enter a licence key'));

  if CheckLicence(FConfigName, FLicence) then
    ActivateLicence(FConfigName, FLicence);

  Application.MessageBox(PChar(_('Licence activated successfully for this installation')), PChar(_('Licence activated')), MB_ICONINFORMATION + MB_OK);
  ModalResult := mrOk;
end;

constructor TfmLicensing.Create(AOwner: TComponent; cConfigName: String);
begin
  inherited Create(AOwner);
  FConfigName := cConfigName;
end;

procedure TfmLicensing.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
end;

end.
