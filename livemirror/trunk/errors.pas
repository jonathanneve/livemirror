unit errors;

interface

uses
  Classes, Sysutils, IniFiles, Generics.Collections;

const
  LOCK_VIOLATION = 'LOCK_VIOLATION';
  FK_VIOLATION = 'FK_VIOLATION';
  OTHER_ROW_ERROR = 'OTHER_ROW_ERROR';
  OTHER_ERROR = 'OTHER_ERROR';
  CONNECTION_ERROR = 'CONNECTION_ERROR';
  NbErrorTypes = 5;
  TCcErrorTypes: array  [1..NbErrorTypes] of string = (LOCK_VIOLATION, FK_VIOLATION, OTHER_ROW_ERROR, OTHER_ERROR, CONNECTION_ERROR);

  TRY_AGAIN_SECONDS = 'TRY_AGAIN_SECONDS';
  CAN_CONTINUE_REPL_CYCLE = 'CAN_CONTINUE_REPL_CYCLE';
  TRY_AGAIN_NEXT_CYCLE = 'TRY_AGAIN_NEXT_CYCLE';
  REPORT_ERROR_EMAIL = 'REPORT_ERROR_EMAIL';
  REPORT_AGAIN_MINUTES = 'REPORT_AGAIN_MINUTES';
  REPORT_WHEN_RESOLVED = 'REPORT_WHEN_RESOLVED';

type

TCcErrorConfigFile = class;
TCcErrorConfig = class
  private
    FTryAgainSeconds: Integer;
    FCanContinueReplCycle: Boolean;
    FReportErrorToEmail: String;
    FTryAgainNextCycle: Boolean;
    FConfigFile: TCcErrorConfigFile;
    FErrorType: string;
    FReportWhenResolved: Boolean;
    FReportAgainMinutes: Integer;
    procedure SetCanContinueReplCycle(const Value: Boolean);
    procedure SetReportErrorToEmail(const Value: String);
    procedure SetTryAgainNextCycle(const Value: Boolean);
    procedure SetTryAgainSeconds(const Value: Integer);
    procedure SetReportAgainMinutes(const Value: Integer);
    procedure SetReportWhenResolved(const Value: Boolean);
    function GetErrorTypeDisplay: String;
  public
    constructor Create(errType: String; confFile: TCcErrorConfigFile);
    property TryAgainSeconds: Integer read FTryAgainSeconds write SetTryAgainSeconds;
    property CanContinueReplCycle: Boolean read FCanContinueReplCycle write SetCanContinueReplCycle;
    property TryAgainNextCycle: Boolean read FTryAgainNextCycle write SetTryAgainNextCycle;
    property ReportErrorToEmail: String read FReportErrorToEmail write SetReportErrorToEmail;
    property ReportAgainMinutes: Integer read FReportAgainMinutes write SetReportAgainMinutes;
    property ReportWhenResolved: Boolean read FReportWhenResolved write SetReportWhenResolved;
    property ErrorType: String read FErrorType;
    property ErrorTypeDisplay: String read GetErrorTypeDisplay;
end;

TCcErrorConfigFile = class
  private
    FIniFile: TIniFile;
    FErrorConfigs: TDictionary<String, TCcErrorConfig>;
  public
    constructor Create(iniFilePath: String);
    destructor Destroy;override;
    property ErrorConfigs : TDictionary<String, TCcErrorConfig> read FErrorConfigs;
end;


implementation

uses gnugettext;

{ TCcErrorConfig }

constructor TCcErrorConfig.Create(errType: String;
  confFile: TCcErrorConfigFile);
var
  I: Integer;
  errorTypeFound: Boolean;
begin
  errorTypeFound := False;
  for I := 1 to NbErrorTypes do
    if errType = TCcErrorTypes[i] then begin
      errorTypeFound := True;
      Break;
    end;

  if not errorTypeFound then
    raise Exception.Create(_('Unknown error type: ') + errorType);

  FErrorType := errType;
  FConfigFile := confFile;
  FTryAgainSeconds := FConfigFile.FIniFile.ReadInteger(errorType, TRY_AGAIN_SECONDS, 0);
  FCanContinueReplCycle := FConfigFile.FIniFile.ReadBool(errorType, CAN_CONTINUE_REPL_CYCLE, True);
  FTryAgainNextCycle := FConfigFile.FIniFile.ReadBool(errorType, TRY_AGAIN_NEXT_CYCLE, False);
  FReportErrorToEmail := FConfigFile.FIniFile.ReadString(errorType, REPORT_ERROR_EMAIL, '');
  FReportAgainMinutes := FConfigFile.FIniFile.ReadInteger(errorType, REPORT_AGAIN_MINUTES, 0);
  ReportWhenResolved := FConfigFile.FIniFile.ReadBool(errorType, REPORT_WHEN_RESOLVED, False);
end;

function TCcErrorConfig.GetErrorTypeDisplay: String;
begin
  if ErrorType = LOCK_VIOLATION then
    Result := _('Lock violation')
  else if ErrorType = FK_VIOLATION then
    Result := _('Foreign key violation')
  else if ErrorType = OTHER_ROW_ERROR then
    Result := _('General row error')
  else if ErrorType = OTHER_ERROR then
    Result := _('General error')
  else if ErrorType = CONNECTION_ERROR then
    Result := _('Connection error')
  else
    Result := ErrorType;
end;

procedure TCcErrorConfig.SetCanContinueReplCycle(const Value: Boolean);
begin
  if FCanContinueReplCycle <> Value then begin
    FCanContinueReplCycle := Value;
    FConfigFile.FIniFile.WriteBool(FErrorType, CAN_CONTINUE_REPL_CYCLE, FCanContinueReplCycle);
  end;
end;

procedure TCcErrorConfig.SetReportAgainMinutes(const Value: Integer);
begin
  if FReportAgainMinutes <> Value then begin
    FReportAgainMinutes := Value;
    FConfigFile.FIniFile.WriteInteger(FErrorType, REPORT_AGAIN_MINUTES, FReportAgainMinutes);
  end;
end;

procedure TCcErrorConfig.SetReportErrorToEmail(const Value: String);
begin
  if FReportErrorToEmail <> Value then begin
    FReportErrorToEmail := Value;
    FConfigFile.FIniFile.WriteString(FErrorType, REPORT_ERROR_EMAIL, FReportErrorToEmail);
  end;
end;

procedure TCcErrorConfig.SetReportWhenResolved(const Value: Boolean);
begin
  if FReportWhenResolved <> Value then begin
    FReportWhenResolved := Value;
    FConfigFile.FIniFile.WriteBool(FErrorType, REPORT_WHEN_RESOLVED, FReportWhenResolved);
  end;
end;

procedure TCcErrorConfig.SetTryAgainNextCycle(const Value: Boolean);
begin
  if FTryAgainNextCycle <> Value then begin
    FTryAgainNextCycle := Value;
    FConfigFile.FIniFile.WriteBool(FErrorType, TRY_AGAIN_NEXT_CYCLE, FTryAgainNextCycle);
  end;
end;

procedure TCcErrorConfig.SetTryAgainSeconds(const Value: Integer);
begin
  if FTryAgainSeconds <> Value then begin
    FTryAgainSeconds := Value;
    FConfigFile.FIniFile.WriteInteger(FErrorType, TRY_AGAIN_SECONDS, FTryAgainSeconds);
  end;
end;

{ TCcErrorConfigFile }

constructor TCcErrorConfigFile.Create(iniFilePath: String);
var
  slSections: TStringList;
  I: Integer;
  errorConf: TCcErrorConfig;
begin
  FIniFile := TIniFile.Create(iniFilePath);
  FErrorConfigs := TDictionary<String, TCcErrorConfig>.Create;
  slSections := TStringList.Create;
  try
    FIniFile.ReadSections(slSections);

    if slSections.Count < NbErrorTypes then begin
      for I := 1 to NbErrorTypes do begin
        if slSections.IndexOf(TCcErrorTypes[i]) = -1 then
          slSections.Add(TCcErrorTypes[i]);
      end;
    end;

    for I := 0 to slSections.Count-1 do
    begin
      errorConf := TCcErrorConfig.Create(slSections[i], Self);
      FErrorConfigs.Add(slSections[i], errorConf);
    end;
  finally
    slSections.Free;
  end;
end;

destructor TCcErrorConfigFile.Destroy;
begin
  FIniFile.Free;
  FErrorConfigs.Free;
  inherited;
end;

end.
