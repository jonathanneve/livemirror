object dmLiveMirrorNode: TdmLiveMirrorNode
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 325
  Width = 598
  object Replicator: TCcReplicator
    TrackInconsistentDeletes = False
    MergeChangedFieldsOnConflict = False
    Direction = sdLocalToRemote
    ReplicateOnlyChangedFields = True
    AutoClearMetadata = True
    FailIfNoPK = False
    TrimCharFields = False
    AutoPriority = True
    OnReplicationResult = ReplicatorReplicationResult
    HarmonizeFields = False
    KeepConnection = True
    AutoReplicate.Frequency = 30
    AutoReplicate.Enabled = False
    AutoCommit.Frequency = 30
    AutoCommit.CommitType = ctNone
    CommitOnFinished = ctNone
    AbortOnError = False
    OnFinished = ReplicatorFinished
    OnRowReplicated = ReplicatorRowReplicated
    OnReplicationError = ReplicatorReplicationError
    OnRowReplicatingError = ReplicatorRowReplicatingError
    OnException = ReplicatorException
    OnReplicationAborted = ReplicatorReplicationAborted
    OnEmptyLog = ReplicatorEmptyLog
    OnConnectLocal = ReplicatorConnectLocal
    OnConnectRemote = ReplicatorConnectRemote
    OnProgress = ReplicatorProgress
    OnLogLoaded = ReplicatorLogLoaded
    BeforeReplicate = ReplicatorBeforeReplicate
    OnConnectionLost = ReplicatorConnectionLost
    Version = '3.9.3'
    KeepRowsInLog = False
    Left = 32
    Top = 24
  end
  object qGenerators: TCcQuery
    SelectStatement = True
    ParamCheck = True
    SQL.Strings = (
      ' select rdb$generator_name as gen_name'
      '  from rdb$generators'
      '  where (rdb$system_flag = 0 or rdb$system_flag is null)')
    Left = 32
    Top = 88
  end
  object qSyncGenerator: TCcQuery
    SelectStatement = False
    ParamCheck = True
    SQL.Strings = (
      'set generator %gen_name to %value')
    Left = 128
    Top = 80
  end
  object CcQuery1: TCcQuery
    SelectStatement = False
    ParamCheck = False
    SQL.Strings = (
      'execute block'
      'returns (gen_name varchar(50), val numeric(18,0))'
      'as'
      'begin'
      '  for select rdb$generator_name '
      '  from rdb$generators'
      
        '  where coalesce(rdb$system_flag, 0) = 0  into :gen_name do begi' +
        'n'
      
        '    execute statement ('#39'select gen_id('#39' || :gen_name || '#39', 0) fr' +
        'om rdb$database'#39') into :val;'
      '    suspend;'
      '  end'
      'end')
    Left = 312
    Top = 32
  end
  object qGetGenValue: TCcQuery
    SelectStatement = True
    ParamCheck = True
    SQL.Strings = (
      'select gen_id(%gen_name, 0) as val from rdb$database')
    Left = 128
    Top = 32
  end
  object qMirrorGenerators: TCcQuery
    SelectStatement = True
    ParamCheck = True
    SQL.Strings = (
      ' select rdb$generator_name as gen_name'
      '  from rdb$generators'
      '  where (rdb$system_flag = 0 or rdb$system_flag is null)')
    Left = 32
    Top = 144
  end
  object FDScript: TFDScript
    SQLScripts = <>
    ScriptOptions.SpoolOutput = smOnReset
    ScriptOptions.SpoolFileName = 'sqlupdates.log'
    ScriptOptions.BreakOnError = True
    ScriptOptions.CommandSeparator = ';'
    Params = <>
    Macros = <>
    Left = 256
    Top = 136
  end
end
