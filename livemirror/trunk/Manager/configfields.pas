unit configfields;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, dconfig;

type
  TfmConfigFields = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lbTables: TListBox;
    lbExcludedFields: TListBox;
    Button1: TButton;
    Button2: TButton;
    cbFieldName: TComboBox;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure lbTablesClick(Sender: TObject);
  private
    FdmConfig: TdmConfig;
    FFieldsExcluded: TStringList;
    FSelectedTableName: string;
    procedure ExcludeField(cFieldName: String);
    procedure RefreshExcludedFields;
    procedure RefreshSelectedTable;
    procedure RefreshFieldList;
    { Private declarations }
  public
    class procedure Display(dmConfig: TdmConfig);
    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

constructor TfmConfigFields.Create(AOwner: TComponent);
begin
  inherited;
  FFieldsExcluded := TStringList.Create;
end;

destructor TfmConfigFields.Destroy;
begin
  FFieldsExcluded.Free;
end;

procedure TfmConfigFields.lbTablesClick(Sender: TObject);
begin
  RefreshSelectedTable;
end;

procedure TfmConfigFields.SpeedButton1Click(Sender: TObject);
begin
  if cbFieldName.ItemIndex <> -1 then begin
    ExcludeField(cbFieldName.Text);
    cbFieldName.Items.Delete(cbFieldName.ItemIndex);
    cbFieldName.ItemIndex := -1;
  end;
end;

procedure TfmConfigFields.ExcludeField(cFieldName: String);
begin
  FFieldsExcluded.Add(FSelectedTableName + '.' + cFieldName);
  RefreshExcludedFields;
  RefreshFieldList;
end;

procedure TfmConfigFields.RefreshFieldList;
var
  I: Integer;
  J: Integer;
begin
    cbFieldName.Items.Assign(FdmConfig.MasterNode.Connection.ListUpdatableTableFields(FSelectedTableName));
  for I := cbFieldName.Items.Count-1 downto 0 do
  begin
    for J := 0 to lbExcludedFields.Items.Count-1 do
    begin
      if cbFieldName.Items[i] = lbExcludedFields.Items[j] then begin
        cbFieldName.Items.Delete(i);
        break;
      end;
    end;
  end;
end;

procedure TfmConfigFields.RefreshSelectedTable;
begin
  if lbTables.ItemIndex <> -1 then begin
    FSelectedTableName := lbTables.Items[lbTables.ItemIndex];
    RefreshExcludedFields;
    RefreshFieldList;
  end
  else
    FSelectedTableName := '';
end;

procedure TfmConfigFields.RefreshExcludedFields;
var
  I: Integer;
  cTableName: String;
  cFieldName: String;
begin
  lbExcludedFields.Items.Clear;
  if lbTables.ItemIndex <> -1 then
  begin
    for I := 0 to FFieldsExcluded.Count-1 do
    begin
      cTableName := Copy(FFieldsExcluded[i], 1, Pos('.', FFieldsExcluded[i]) - 1);
      cFieldName := Copy(FFieldsExcluded[i], Pos('.', FFieldsExcluded[i]) + 1, Length(FFieldsExcluded[i]));
      if cTableName = FSelectedTableName then
        lbExcludedFields.Items.Add(cFieldName);
    end;
  end;
end;

class procedure TfmConfigFields.Display(dmConfig: TdmConfig);
var
  I, index: Integer;
  slTablesExcluded: TStringList;
  fmConfigFields: TfmConfigFields;
begin
  fmConfigFields := TfmConfigFields.Create(Application);

  with fmConfigFields do begin
    FdmConfig := dmConfig;
    FFieldsExcluded.CommaText := dmConfig.ExcludedFields;

    dmConfig.MasterNode.connection.Connect;
    lbTables.Items.Assign(dmConfig.MasterNode.connection.ListTables);
    for i := lbTables.Items.Count-1 downto 0 do begin
      if Copy(lbTables.Items[I], 1, 4) = 'RPL$'  then
        lbTables.Items.Delete(I);
    end;
    slTablesExcluded := TStringList.Create;
    try
      slTablesExcluded.CommaText := dmConfig.ExcludedTables;
      for i := 0 to slTablesExcluded.Count-1 do begin
        index := lbTables.Items.IndexOf(slTablesExcluded[I]);
        if index <> -1 then
          lbTables.Items.Delete(index);
      end;
    finally
      slTablesExcluded.Free;
    end;

    lbTables.ItemIndex := 0;
    RefreshSelectedTable;

    if (ShowModal = mrOk) then
      dmConfig.ExcludedFields := FFieldsExcluded.CommaText;
    dmConfig.MasterNode.connection.Disconnect;
    Free;
  end;
end;

end.
