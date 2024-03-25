object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 432
  Width = 701
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=J:\Projetos\ProjetoAvaliacaoSoftplan\DB\DBCONSULTACEP.f' +
        'db'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB'
      'CharacterSet=WIN1252'
      'Server=localhost')
    Connected = True
    LoginPrompt = False
    Left = 72
    Top = 32
  end
  object FDTransaction: TFDTransaction
    Connection = FDConnection
    Left = 72
    Top = 80
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection
    Left = 72
    Top = 128
  end
  object DS_CDSPesquisa: TDataSource
    DataSet = CDSPesquisa
    Left = 232
    Top = 136
  end
  object CDSPesquisa: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 264
    Top = 136
    object CDSPesquisaCEP: TStringField
      FieldName = 'CEP'
      EditMask = '00\.000\-000;0;_'
      Size = 10
    end
    object CDSPesquisaLOGRADOURO: TStringField
      DisplayWidth = 500
      FieldName = 'LOGRADOURO'
      Size = 500
    end
    object CDSPesquisaLOCALIDADE: TStringField
      FieldName = 'LOCALIDADE'
      Size = 150
    end
    object CDSPesquisaUF: TStringField
      FieldName = 'UF'
      Size = 2
    end
  end
  object DS_QueryCep: TDataSource
    DataSet = FDQueryCep
    Left = 232
    Top = 192
  end
  object FDQueryCep: TFDQuery
    AfterInsert = FDQueryCepAfterInsert
    BeforePost = FDQueryCepBeforePost
    Connection = FDConnection
    SQL.Strings = (
      'SELECT * FROM CEP')
    Left = 264
    Top = 192
    object FDQueryCepCODIGO: TIntegerField
      FieldName = 'CODIGO'
      Origin = 'CODIGO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object FDQueryCepCEP: TStringField
      FieldName = 'CEP'
      Origin = 'CEP'
      Size = 10
    end
    object FDQueryCepLOGRADOURO: TStringField
      FieldName = 'LOGRADOURO'
      Origin = 'LOGRADOURO'
      Size = 1000
    end
    object FDQueryCepCOMPLEMENTO: TStringField
      FieldName = 'COMPLEMENTO'
      Origin = 'COMPLEMENTO'
      Size = 500
    end
    object FDQueryCepBAIRRO: TStringField
      FieldName = 'BAIRRO'
      Origin = 'BAIRRO'
      Size = 500
    end
    object FDQueryCepLOCALIDADE: TStringField
      FieldName = 'LOCALIDADE'
      Origin = 'LOCALIDADE'
      Size = 500
    end
    object FDQueryCepUF: TStringField
      FieldName = 'UF'
      Origin = 'UF'
      Size = 2
    end
  end
  object FDQueryAux: TFDQuery
    Connection = FDConnection
    Left = 72
    Top = 184
  end
end
