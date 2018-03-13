unit erroroptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, fErrorConfig,
  fGeneralErrorConfig, errors;

type
  TfmErrorOptions = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    frLockError: TfrErrorConfig;
    frFKError: TfrErrorConfig;
    frOtherRowError: TfrErrorConfig;
    frConnectionError: TfrGeneralErrorConfig;
    frOtherGeneralError: TfrGeneralErrorConfig;
    Button1: TButton;
    GroupBox3: TGroupBox;
    Edit1: TEdit;
    Label2: TLabel;
    Label1: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
  private
    FErrorConfigFile: TCcErrorConfigFile;
    { Private declarations }
  public
    procedure Init(iniFilePath: String);
  end;

implementation

{$R *.dfm}

procedure TfmErrorOptions.Init(iniFilePath: String);
begin
  FErrorConfigFile := TCcErrorConfigFile.Create(iniFilePath);
  frConnectionError.Init(FErrorConfigFile.ErrorConfigs[CONNECTION_ERROR]);
  frOtherGeneralError.Init(FErrorConfigFile.ErrorConfigs[OTHER_ERROR]);
  frLockError.Init(FErrorConfigFile.ErrorConfigs[LOCK_VIOLATION]);
  frFKError.Init(FErrorConfigFile.ErrorConfigs[FK_VIOLATION]);
  frOtherRowError.Init(FErrorConfigFile.ErrorConfigs[OTHER_ROW_ERROR]);
end;

end.
