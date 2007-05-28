object dmLogsAndSettings: TdmLogsAndSettings
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 483
  Top = 232
  Height = 401
  Width = 521
  object CcReplicatorList: TCcReplicatorList
    ConfigStorage = CcConfigStorage
    Version = '2.00.0'
    OnFinished = CcReplicatorListFinished
    OnRowReplicated = CcReplicatorListRowReplicated
    OnReplicationError = CcReplicatorListReplicationError
    OnException = CcReplicatorListException
    OnEmptyLog = CcReplicatorListEmptyLog
    OnLogLoaded = CcReplicatorListLogLoaded
    Left = 40
    Top = 64
  end
  object CcConfigStorage: TCcConfigStorage
    UseRegistry = False
    Left = 128
    Top = 8
  end
  object CcDataSet1: TCcDataSet
    Left = 128
    Top = 64
  end
  object CcConfig: TCcConfig
    ConfigStorage = CcConfigStorage
    Version = '2.00.0'
    DatabaseNode = dnLocal
    Terminator = #167
    Left = 40
    Top = 8
  end
  object CcConfigStorageDS: TDataSource
    DataSet = CcConfigStorage
    Left = 240
    Top = 8
  end
  object FrameController: TRzFrameController
    DisabledColor = 14278369
    FocusColor = 13828095
    FrameColor = 12164479
    FrameHotTrack = True
    FrameVisible = True
    Left = 344
    Top = 8
  end
  object dbLog: TpFIBDatabase
    DBName = 'c:\projects\livemirror\log.fdb'
    DBParams.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'sql_role_name=')
    DefaultTransaction = trLog
    DefaultUpdateTransaction = trLog
    SQLDialect = 1
    Timeout = 0
    DesignDBOptions = []
    LibraryName = 'fbembed.dll'
    WaitForRestoreConnect = 0
    Left = 40
    Top = 128
  end
  object trLog: TpFIBTransaction
    DefaultDatabase = dbLog
    TimeoutAction = TACommit
    Left = 128
    Top = 128
  end
  object qRPLTables: TCcQuery
    ParamCheck = True
    MetaSQL = sqlNone
    SQL.Strings = (
      'SELECT TABLE_NAME'
      'FROM RPL$TABLES'
      'WHERE %condition')
    Left = 240
    Top = 64
  end
  object qInsertAlias: TpFIBQuery
    Transaction = trLog
    Database = dbLog
    SQL.Strings = (
      'INSERT INTO ALIASES(CONFIG_NAME)'
      'VALUES (:CONFIG_NAME)'
      '')
    Left = 232
    Top = 184
  end
  object qInsertUser: TCcQuery
    ParamCheck = True
    MetaSQL = sqlNone
    SQL.Strings = (
      
        'INSERT INTO RPL$USERS (RPL$USERS.LOGIN, RPL$USERS.LIBELLE, RPL$U' +
        'SERS.CONDITION_VALUE)'
      'VALUES (:ALIAS_NAME, NULL, NULL);')
    Left = 440
    Top = 64
  end
  object qUser: TCcQuery
    ParamCheck = True
    MetaSQL = sqlNone
    SQL.Strings = (
      
        'SELECT RPL$USERS.LOGIN FROM RPL$USERS WHERE (RPL$USERS.LOGIN = :' +
        'USER_NAME);')
    Left = 344
    Top = 64
  end
  object qFindAlias: TpFIBQuery
    Transaction = trLog
    Database = dbLog
    SQL.Strings = (
      'SELECT ALIAS_ID '
      'from aliases'
      'where config_name = :config_name')
    Left = 232
    Top = 128
  end
  object qInsertLog: TpFIBQuery
    Transaction = trLog
    Database = dbLog
    SQL.Strings = (
      'insert into log (LOG_ID,'
      '  DATE_SYNC,'
      '  RECORDS_OK,'
      '  RECORDS_ERROR,'
      '  TRANSFER_STATUS,'
      '  CONFIG_NAME)'
      'values '
      '(:LOG_ID,'
      '  '#39'now'#39','
      '  0,'
      '  0,'
      '  0,'
      '  :config_name)')
    Left = 232
    Top = 240
  end
  object qDeleteAlias: TpFIBQuery
    Transaction = trLog
    Database = dbLog
    SQL.Strings = (
      'delete from aliases where config_name = :config_name')
    Left = 344
    Top = 128
  end
  object qUpdateLog: TpFIBQuery
    Transaction = trLog
    Database = dbLog
    SQL.Strings = (
      'update log'
      'set records_ok = records_ok + :INC_RECORDS_OK,'
      'RECORDS_ERROR = RECORDS_ERROR + :INC_RECORDS_ERROR, '
      'TRANSFER_STATUS = :TRANSFER_STATUS'
      'where log_id = :log_id')
    Left = 344
    Top = 192
  end
  object qInsertLogError: TpFIBQuery
    Transaction = trLog
    Database = dbLog
    SQL.Strings = (
      'insert into LOG_ERRORS'
      '(LOG_ID, TABLE_NAME, PRIMARY_KEYS, ERROR_MESSAGE) '
      'values'
      '(:LOG_ID,:TABLE_NAME,:PRIMARY_KEYS,:ERROR_MESSAGE)')
    Left = 232
    Top = 296
  end
end
