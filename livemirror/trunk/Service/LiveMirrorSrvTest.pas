unit LiveMirrorSrvTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses main;

procedure TForm1.FormCreate(Sender: TObject);
var
  lm : TLiveMirror;
begin
  lm :=TLiveMirror.Create(Self);
  lm.Initialize;
end;

end.
