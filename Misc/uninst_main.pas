unit uninst_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfmMain = class(TForm)
    ShowTimer: TTimer;
    memLog: TMemo;
    procedure ShowTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses IniFiles, gnugettext, LMUtils;

procedure TfmMain.FormShow(Sender: TObject);
begin
  ShowTimer.Enabled := True;
end;

procedure TfmMain.ShowTimerTimer(Sender: TObject);
var
  ini: TIniFile;
  I: Integer;
  slSections: TStringList;
  cLicence, cConfigName: String;
begin
  ShowTimer.Enabled := False;

  ini := TIniFile.Create(GetLiveMirrorRoot + '\configs.ini');
  slSections := TStringList.Create;
  try
    ini.ReadSections(slSections);
    for I := 0 to slSections.Count-1 do begin
      cConfigName := slSections[I];
      memLog.Lines.Add(Format(_('Configuration %s :'), [cConfigName]));
      Application.ProcessMessages;

      cLicence := ini.ReadString(cConfigName, 'Licence', '');
      if cLicence <> '' then begin
        memLog.Lines.Add(_('Deactivating licence'));
        Application.ProcessMessages;
        DeactivateLicence(cConfigName, cLicence);
      end;
      memLog.Lines.Add(_('Uninstalling service'));
      Application.ProcessMessages;
      UnInstallService(cConfigName, Handle);
      Application.ProcessMessages;
    end;
  finally
    ini.Free;
    slSections.Free;
  end;
  Application.Terminate;
end;

end.
