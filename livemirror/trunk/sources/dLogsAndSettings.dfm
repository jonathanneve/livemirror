object dmLogsAndSettings: TdmLogsAndSettings
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 277
  Top = 154
  Height = 461
  Width = 809
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
  object ibdLog: TpFIBDatabase
    DBParams.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'sql_role_name=')
    SQLDialect = 1
    Timeout = 0
    LibraryName = 'fbembed.dll'
    WaitForRestoreConnect = 0
    Left = 40
    Top = 128
  end
  object ibtSelectAliases: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 128
    Top = 128
  end
  object ibqSelectAliases: TpFIBQuery
    Transaction = ibtSelectAliases
    Database = ibdLog
    SQL.Strings = (
      'SELECT :ALIAS_ID,'
      '               :CONFIG_ID,'
      '               :CONFIG_NAME,'
      '               :DATE_SYNC,'
      '               :RECORDS_ERROR,'
      '               :TRANSFER_STATUS'
      'FROM SELECT_ALIASES(-1);')
    Left = 240
    Top = 128
  end
  object dtsSelectAliasesDS: TDataSource
    DataSet = dtsSelectAliases
    Left = 440
    Top = 128
  end
  object dtsSelectAliases: TpFIBDataSet
    SelectSQL.Strings = (
      'SELECT *'
      'FROM SELECT_ALIASES(-1);')
    Transaction = ibtSelectAliases
    Database = ibdLog
    Left = 344
    Top = 128
    oRefreshDeletedRecord = True
    object dtsSelectAliasesALIAS_ID: TFIBIntegerField
      FieldName = 'ALIAS_ID'
    end
    object dtsSelectAliasesCONFIG_ID: TFIBIntegerField
      FieldName = 'CONFIG_ID'
    end
    object dtsSelectAliasesCONFIG_NAME: TFIBStringField
      FieldName = 'CONFIG_NAME'
      Size = 100
      EmptyStrToNull = True
    end
    object dtsSelectAliasesDATE_SYNC: TFIBDateTimeField
      FieldName = 'DATE_SYNC'
      OnGetText = DoConvertDateTimeAsLocalSettings
      DisplayFormat = 'dd.mm.yyyy hh:mm AMPM'
    end
    object dtsSelectAliasesRECORDS_ERROR: TFIBIntegerField
      FieldName = 'RECORDS_ERROR'
    end
    object dtsSelectAliasesTRANSFER_STATUS: TFIBSmallIntField
      FieldName = 'TRANSFER_STATUS'
    end
    object dtsSelectAliasesCONVERTED_STATUS: TStringField
      FieldKind = fkCalculated
      FieldName = 'CONVERTED_STATUS'
      OnGetText = DoConvertStatus
      Size = 0
      Calculated = True
    end
  end
  object ccqSelectRplTables: TCcQuery
    ParamCheck = True
    MetaSQL = sqlNone
    SQL.Strings = (
      'SELECT RPL$TABLES.TABLE_NAME'
      'FROM RPL$TABLES'
      
        'WHERE ( (RPL$TABLES.CREATED <> '#39'Y'#39') OR (RPL$TABLES.CREATED IS NU' +
        'LL) )')
    Left = 240
    Top = 64
  end
  object ibsInsertAlias: TpFIBStoredProc
    Transaction = ibtInsertAlias
    Database = ibdLog
    SQL.Strings = (
      'EXECUTE PROCEDURE INSERT_ALIAS(:CONFIG_ID, :CONFIG_NAME);')
    Left = 240
    Top = 240
  end
  object ibtInsertAlias: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 128
    Top = 240
  end
  object ccqInsertUser: TCcQuery
    ParamCheck = True
    MetaSQL = sqlNone
    SQL.Strings = (
      
        'INSERT INTO RPL$USERS (RPL$USERS.LOGIN, RPL$USERS.LIBELLE, RPL$U' +
        'SERS.CONDITION_VALUE)'
      'VALUES (:ALIAS_NAME, NULL, NULL);')
    Left = 440
    Top = 64
  end
  object ccqSelectUser: TCcQuery
    ParamCheck = True
    MetaSQL = sqlNone
    SQL.Strings = (
      
        'SELECT RPL$USERS.LOGIN FROM RPL$USERS WHERE (RPL$USERS.LOGIN = :' +
        'USER_NAME);')
    Left = 344
    Top = 64
  end
  object ibtSelectAliasByName: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 128
    Top = 184
  end
  object ibqSelectAliasByName: TpFIBQuery
    Transaction = ibtSelectAliasByName
    Database = ibdLog
    SQL.Strings = (
      'SELECT ALIAS_ID,'
      '               CONFIG_ID,'
      '               CONFIG_NAME'
      'FROM SELECT_ALIAS_BY_NAME(:NAME);')
    Left = 240
    Top = 184
  end
  object ibtInsertLog: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 128
    Top = 296
  end
  object ibsInsertLog: TpFIBStoredProc
    Transaction = ibtInsertLog
    Database = ibdLog
    SQL.Strings = (
      'EXECUTE PROCEDURE INSERT_LOG (:CONFIG_ID)')
    Left = 240
    Top = 296
  end
  object ibtDeleteAlias: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 344
    Top = 240
  end
  object ibsDeleteAlias: TpFIBStoredProc
    Transaction = ibtDeleteAlias
    Database = ibdLog
    SQL.Strings = (
      'EXECUTE PROCEDURE DELETE_ALIAS (:ALIAS_ID)')
    Left = 440
    Top = 240
  end
  object ibtInsertLogError: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 128
    Top = 360
  end
  object ibtUpdateLog: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 344
    Top = 296
  end
  object ibsUpdateLog: TpFIBStoredProc
    Transaction = ibtUpdateLog
    Database = ibdLog
    SQL.Strings = (
      
        'EXECUTE PROCEDURE UPDATE_LOG (:LOG_ID,:INC_RECORDS_OK,:INC_RECOR' +
        'DS_ERROR,:TRANSFER_STATUS);')
    Left = 440
    Top = 296
  end
  object ibtSelectLog: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 544
    Top = 240
  end
  object dtsSelectLog: TpFIBDataSet
    SelectSQL.Strings = (
      'SELECT '#9'LOG_ID,'
      '           '#9'CONFIG_ID,'
      #9'CONFIG_NAME,'
      '           '#9'DATE_SYNC,'
      '           '#9'RECORDS_OK,'
      '           '#9'RECORDS_ERROR,'
      '           '#9'TRANSFER_STATUS'
      'FROM SELECT_LOG(:ID);')
    Transaction = ibtSelectLog
    Database = ibdLog
    DataSource = CcConfigStorageDS
    Left = 632
    Top = 240
    object dtsSelectLogLOG_ID: TFIBIntegerField
      FieldName = 'LOG_ID'
    end
    object dtsSelectLogCONFIG_ID: TFIBIntegerField
      FieldName = 'CONFIG_ID'
    end
    object dtsSelectLogCONFIG_NAME: TFIBStringField
      FieldName = 'CONFIG_NAME'
      Size = 200
      EmptyStrToNull = True
    end
    object dtsSelectLogDATE_SYNC: TFIBDateTimeField
      FieldName = 'DATE_SYNC'
      OnGetText = DoConvertDateTimeAsLocalSettings
    end
    object dtsSelectLogRECORDS_OK: TFIBIntegerField
      FieldName = 'RECORDS_OK'
    end
    object dtsSelectLogRECORDS_ERROR: TFIBIntegerField
      FieldName = 'RECORDS_ERROR'
    end
    object dtsSelectLogTRANSFER_STATUS: TFIBSmallIntField
      FieldName = 'TRANSFER_STATUS'
    end
    object dtsSelectLogCONVERTED_STATUS: TStringField
      FieldKind = fkCalculated
      FieldName = 'CONVERTED_STATUS'
      OnGetText = DoConvertStatus
      Calculated = True
    end
  end
  object dtsSelectLogDS: TDataSource
    DataSet = dtsSelectLog
    OnDataChange = dtsSelectLogDSDataChange
    Left = 712
    Top = 240
  end
  object ibsInsertLogError: TpFIBStoredProc
    Transaction = ibtInsertLogError
    Database = ibdLog
    SQL.Strings = (
      
        'EXECUTE PROCEDURE INSERT_LOG_ERROR (:LOG_ID,:TABLE_NAME,:PRIMARY' +
        '_KEYS,:ERROR_MESSAGE);')
    Left = 240
    Top = 360
  end
  object ibtSelectLogErrors: TpFIBTransaction
    DefaultDatabase = ibdLog
    TimeoutAction = TARollback
    Left = 552
    Top = 360
  end
  object dtsSelectLogErrors: TpFIBDataSet
    SelectSQL.Strings = (
      'SELECT'#9'LOG_ERROR_ID,'
      #9'LOG_ID,'
      '     '#9'TABLE_NAME,'
      '     '#9'PRIMARY_KEYS,'
      '     '#9'ERROR_MESSAGE'
      'FROM SELECT_LOG_ERRORS(:ID);')
    Transaction = ibtSelectLogErrors
    Database = ibdLog
    DataSource = CcConfigStorageDS
    Left = 640
    Top = 360
    object dtsSelectLogErrorsLOG_ERROR_ID: TFIBIntegerField
      FieldName = 'LOG_ERROR_ID'
    end
    object dtsSelectLogErrorsLOG_ID: TFIBIntegerField
      FieldName = 'LOG_ID'
    end
    object dtsSelectLogErrorsTABLE_NAME: TFIBStringField
      FieldName = 'TABLE_NAME'
      Size = 100
      EmptyStrToNull = True
    end
    object dtsSelectLogErrorsPRIMARY_KEYS: TFIBStringField
      FieldName = 'PRIMARY_KEYS'
      Size = 500
      EmptyStrToNull = True
    end
    object dtsSelectLogErrorsERROR_MESSAGE: TFIBMemoField
      FieldName = 'ERROR_MESSAGE'
      BlobType = ftMemo
      Size = 8
    end
    object dtsSelectLogErrorsCONVERTED_MESSAGE: TStringField
      FieldKind = fkCalculated
      FieldName = 'CONVERTED_MESSAGE'
      OnGetText = DoConvertMessage
      Calculated = True
    end
  end
  object dtsSelectLogErrorsDS: TDataSource
    DataSet = dtsSelectLogErrors
    Left = 720
    Top = 360
  end
end
