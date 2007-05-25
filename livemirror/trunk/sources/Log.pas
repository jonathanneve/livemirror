unit Log;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, RzButton, RzTabs, ExtCtrls, RzPanel, StdCtrls, RzLabel,
	fConfServer, Grids, DBGridEh, LiveMirrorInterfaces, RzSplit, dLogsAndSettings,
	Mask, RzEdit, RzDBEdit, DBCtrls, DB, FIBDataSet, pFIBDataSet;

type
	TfmLog = class(TForm)
		pnlButtons: TRzPanel;
		btnClose: TRzBitBtn;
		pnlInfos: TRzPanel;
		lblAliasName: TRzLabel;
		dbgLog: TDBGridEh;
    lbAlias: TLabel;
    pnErrors: TRzSizePanel;
		dbgLogErrors: TDBGridEh;
		lblErrorsDetails: TLabel;
    qLog: TpFIBDataSet;
    qLogDS: TDataSource;
    qLogErrors: TpFIBDataSet;
    qLogErrorsDS: TDataSource;
    qLogErrorsLOG_ERROR_ID: TFIBIntegerField;
    qLogErrorsLOG_ID: TFIBIntegerField;
    qLogErrorsTABLE_NAME: TFIBStringField;
    qLogErrorsPRIMARY_KEYS: TFIBStringField;
    qLogErrorsERROR_MESSAGE: TFIBMemoField;
    qLogLOG_ID: TFIBIntegerField;
    qLogDATE_SYNC: TFIBDateTimeField;
    qLogRECORDS_OK: TFIBIntegerField;
    qLogRECORDS_ERROR: TFIBIntegerField;
    qLogTRANSFER_STATUS: TFIBSmallIntField;
    qLogCONFIG_NAME: TFIBStringField;
    qLogALIAS_ID: TFIBIntegerField;
    qLogCONFIG_NAME1: TFIBStringField;
    qLogStatus: TStringField;
		procedure btnCloseClick(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure qLogDSDataChange(Sender: TObject; Field: TField);
    procedure qLogCalcFields(DataSet: TDataSet);
	private
		{ Private declarations }
    cConfigName: String;
		FISettingsModel: ISettingsModel;
    procedure OnLog(AConfigName: String);
    procedure RefreshLog;
    procedure OnLogError(AConfigName: String; LogID: Integer);
    procedure RefreshLogErrors;
	public
		{ Public declarations }
		constructor Create(AOwner: TComponent; AISettingsModel: ISettingsModel); reintroduce; virtual;
		destructor Destroy(); override;
	end;

var
  fmLog: TfmLog;

implementation

{$R *.dfm}

constructor TfmLog.Create(AOwner: TComponent; AISettingsModel: ISettingsModel);
begin
	inherited Create(AOwner);
	FISettingsModel := AISettingsModel;
	FISettingsModel.OnRefreshLog := OnLog;
	FISettingsModel.OnRefreshLogError := OnLogError;
  cConfigName := dmLogsAndSettings.CcConfigStorage.FieldByName('ConfigName').AsString;
  lbAlias.Caption := cConfigName;
  RefreshLog;
end;
//-----------------------------------------------------------------------------
destructor TfmLog.Destroy();
begin
  FISettingsModel.OnRefreshLog := nil;
  FISettingsModel.OnRefreshLogError := nil;
	FISettingsModel := nil;
	inherited Destroy();
end;
//-----------------------------------------------------------------------------
procedure TfmLog.OnLog(AConfigName: String);
begin
  if AConfigName = cConfigName then
    RefreshLog;
end;
//-----------------------------------------------------------------------------
procedure TfmLog.OnLogError(AConfigName: String; LogID: Integer);
begin
  if AConfigName = cConfigName then
    RefreshLogErrors;
end;
//-----------------------------------------------------------------------------
procedure TfmLog.RefreshLog;
begin
	qLog.Close();
	qLog.ParamByName('CONFIG_NAME').Value := cConfigName;
	qLog.Open();
end;
//-----------------------------------------------------------------------------
procedure TfmLog.RefreshLogErrors;
begin
	qLogErrors.Close;
	qLogErrors.ParamByName('LOG_ID').Value := qLogLOG_ID.Value;
	qLogErrors.Open;
  if qLogErrors.RecordCount > 0 then
    pnErrors.RestoreHotSpot
  else
    pnErrors.CloseHotSpot;
end;
//-----------------------------------------------------------------------------
procedure TfmLog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	Action := caFree;
	fmLog := nil;
end;
//-----------------------------------------------------------------------------
procedure TfmLog.btnCloseClick(Sender: TObject);
begin
	Self.Close();
end;
//-----------------------------------------------------------------------------

procedure TfmLog.qLogDSDataChange(Sender: TObject; Field: TField);
begin
  RefreshLogErrors;
end;

procedure TfmLog.qLogCalcFields(DataSet: TDataSet);
begin
  if (not qLogTRANSFER_STATUS.AsBoolean) then
    qLogStatus.Value := 'Running...'
  else if (qLogRECORDS_ERROR.Value = 0) then
    qLogStatus.Value := 'Completed successfully'
  else
    qLogStatus.Value := 'Completed with errors';
end;

end.
