unit configoptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, IniFiles, CcProviders,
  dconfig;

type
  TfmConfigOptions = class(TForm)
    lbTablesIncluded: TListBox;
    Label1: TLabel;
    lbTablesExcluded: TListBox;
    Label2: TLabel;
    btExclude: TSpeedButton;
    btInclude: TSpeedButton;
    Button1: TButton;
    Button2: TButton;
    procedure btExcludeClick(Sender: TObject);
    procedure btIncludeClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowOptions(dmConfig: TdmConfig);
    { Public declarations }
  end;

var
  fmConfigOptions: TfmConfigOptions;

implementation

{$R *.dfm}

procedure TfmConfigOptions.ShowOptions(dmConfig: TdmConfig);
var
  I, index: Integer;
begin
  dmConfig.MasterNode.connection.Connect;
  lbTablesIncluded.Items.Assign(dmConfig.MasterNode.connection.ListTables);
  for i := lbTablesIncluded.Items.Count-1 downto 0 do begin
    if Copy(lbTablesIncluded.Items[I], 1, 4) = 'RPL$'  then
      lbTablesIncluded.Items.Delete(I);
  end;
  lbTablesExcluded.Items.CommaText := dmConfig.ExcludedTables;
  for i := 0 to lbTablesExcluded.Items.Count-1 do begin
    index := lbTablesIncluded.Items.IndexOf(lbTablesExcluded.Items[I]);
    if index <> -1 then
      lbTablesIncluded.Items.Delete(index);
  end;

  if (ShowModal = mrOk) then
    dmConfig.ExcludedTables := lbTablesExcluded.Items.CommaText;
  dmConfig.MasterNode.connection.Disconnect;
end;

procedure TfmConfigOptions.btExcludeClick(Sender: TObject);
begin
  lbTablesIncluded.MoveSelection(lbTablesExcluded);
end;

procedure TfmConfigOptions.btIncludeClick(Sender: TObject);
begin
  lbTablesExcluded.MoveSelection(lbTablesIncluded);
end;

end.
