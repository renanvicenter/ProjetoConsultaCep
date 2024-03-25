object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Consulta CEP'
  ClientHeight = 468
  ClientWidth = 885
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 885
    Height = 113
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object PageControl: TPageControl
      Left = 0
      Top = 0
      Width = 585
      Height = 113
      ActivePage = TabSheetConsultaPorEndereco
      Align = alLeft
      TabHeight = 30
      TabOrder = 0
      object TabSheetConsultaCep: TTabSheet
        Caption = 'Consulta por CEP'
        object LabelCEP: TLabel
          Left = 15
          Top = 11
          Width = 20
          Height = 13
          Caption = 'CEP'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object DBEditCEPPesquisa: TDBEdit
          Left = 15
          Top = 30
          Width = 121
          Height = 21
          DataField = 'CEP'
          DataSource = DM.DS_CDSPesquisa
          TabOrder = 0
        end
      end
      object TabSheetConsultaPorEndereco: TTabSheet
        Caption = 'Consulta por Endere'#231'o'
        ImageIndex = 1
        object Label1: TLabel
          Left = 15
          Top = 11
          Width = 14
          Height = 13
          Caption = 'UF'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label2: TLabel
          Left = 71
          Top = 11
          Width = 104
          Height = 13
          Caption = 'Localidade/Cidade'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label9: TLabel
          Left = 220
          Top = 11
          Width = 65
          Height = 13
          Caption = 'Logradouro'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object DBEditLocalidadePesquisa: TDBEdit
          Left = 71
          Top = 30
          Width = 143
          Height = 21
          DataField = 'LOCALIDADE'
          DataSource = DM.DS_CDSPesquisa
          TabOrder = 1
        end
        object DBEditLogradouroPesquisa: TDBEdit
          Left = 220
          Top = 30
          Width = 346
          Height = 21
          DataField = 'LOGRADOURO'
          DataSource = DM.DS_CDSPesquisa
          TabOrder = 2
        end
        object DBComboBoxUF: TDBComboBox
          Left = 15
          Top = 30
          Width = 50
          Height = 21
          Style = csDropDownList
          DataField = 'UF'
          DataSource = DM.DS_CDSPesquisa
          Items.Strings = (
            'AC'
            'AL'
            'AP'
            'AM'
            'BA'
            'CE'
            'DF'
            'ES'
            'GO'
            'MA'
            'MT'
            'MS'
            'MG'
            'PA'
            'PB'
            'PR'
            'PE'
            'PI'
            'RJ'
            'RN'
            'RS'
            'RO'
            'RR'
            'SC'
            'SP'
            'SE'
            'TO')
          TabOrder = 0
        end
      end
    end
    object RadioGroupFormatoConsulta: TRadioGroup
      Left = 585
      Top = 0
      Width = 120
      Height = 113
      Align = alLeft
      Caption = 'Formato Consulta'
      ItemIndex = 0
      Items.Strings = (
        'JSON'
        'XML')
      TabOrder = 1
    end
    object BitBtnConsultar: TBitBtn
      Left = 716
      Top = 14
      Width = 165
      Height = 35
      Caption = '&Consultar'
      TabOrder = 2
      OnClick = BitBtnConsultarClick
    end
    object BitBtnLimparCampos: TBitBtn
      Left = 716
      Top = 55
      Width = 165
      Height = 35
      Caption = '&Limpar Campos'
      TabOrder = 3
      OnClick = BitBtnLimparCamposClick
    end
  end
  object PanelClient: TPanel
    Left = 0
    Top = 113
    Width = 885
    Height = 355
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object GroupBoxResultadoConsulta: TGroupBox
      Left = 0
      Top = 0
      Width = 704
      Height = 355
      Align = alClient
      Caption = 'Resultado Consulta CEP'
      TabOrder = 0
      object Panel1: TPanel
        Left = 2
        Top = 15
        Width = 700
        Height = 338
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Label3: TLabel
          Left = 17
          Top = 8
          Width = 20
          Height = 13
          Caption = 'CEP'
          FocusControl = DBEditCEP
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label4: TLabel
          Left = 17
          Top = 45
          Width = 65
          Height = 13
          Caption = 'Logradouro'
          FocusControl = DBEditLogradouro
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label5: TLabel
          Left = 17
          Top = 88
          Width = 79
          Height = 13
          Caption = 'Complemento'
          FocusControl = DBEditComplemento
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label6: TLabel
          Left = 17
          Top = 128
          Width = 34
          Height = 13
          Caption = 'Bairro'
          FocusControl = DBEditBairro
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label7: TLabel
          Left = 17
          Top = 168
          Width = 104
          Height = 13
          Caption = 'Localidade/Cidade'
          FocusControl = DBEditLocalidade
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label8: TLabel
          Left = 157
          Top = 8
          Width = 14
          Height = 13
          Caption = 'UF'
          FocusControl = DBEditUF
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object DBGridCEP: TDBGrid
          Left = 0
          Top = 223
          Width = 700
          Height = 115
          Align = alBottom
          DataSource = DM.DS_QueryCep
          DrawingStyle = gdsGradient
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 6
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
          Columns = <
            item
              Expanded = False
              FieldName = 'CEP'
              Title.Alignment = taCenter
              Width = 70
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'UF'
              Title.Alignment = taCenter
              Width = 25
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'LOGRADOURO'
              Title.Alignment = taCenter
              Title.Caption = 'Logradouro'
              Width = 250
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'COMPLEMENTO'
              Title.Alignment = taCenter
              Title.Caption = 'Complemento'
              Width = 100
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'BAIRRO'
              Title.Alignment = taCenter
              Title.Caption = 'Bairro'
              Width = 108
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'LOCALIDADE'
              Title.Alignment = taCenter
              Title.Caption = 'Localidade / Cidade'
              Width = 150
              Visible = True
            end>
        end
        object DBEditCEP: TDBEdit
          Left = 17
          Top = 24
          Width = 134
          Height = 21
          DataField = 'CEP'
          DataSource = DM.DS_QueryCep
          ReadOnly = True
          TabOrder = 0
        end
        object DBEditLogradouro: TDBEdit
          Left = 17
          Top = 64
          Width = 670
          Height = 21
          DataField = 'LOGRADOURO'
          DataSource = DM.DS_QueryCep
          ReadOnly = True
          TabOrder = 2
        end
        object DBEditComplemento: TDBEdit
          Left = 17
          Top = 104
          Width = 670
          Height = 21
          DataField = 'COMPLEMENTO'
          DataSource = DM.DS_QueryCep
          ReadOnly = True
          TabOrder = 3
        end
        object DBEditBairro: TDBEdit
          Left = 17
          Top = 144
          Width = 670
          Height = 21
          DataField = 'BAIRRO'
          DataSource = DM.DS_QueryCep
          ReadOnly = True
          TabOrder = 4
        end
        object DBEditLocalidade: TDBEdit
          Left = 17
          Top = 187
          Width = 670
          Height = 21
          DataField = 'LOCALIDADE'
          DataSource = DM.DS_QueryCep
          ReadOnly = True
          TabOrder = 5
        end
        object DBEditUF: TDBEdit
          Left = 157
          Top = 24
          Width = 30
          Height = 21
          DataField = 'UF'
          DataSource = DM.DS_QueryCep
          ReadOnly = True
          TabOrder = 1
        end
      end
    end
    object GroupBox1: TGroupBox
      Left = 704
      Top = 0
      Width = 181
      Height = 355
      Align = alRight
      Caption = 'Retorno da consulta'
      TabOrder = 1
      object MemoRetornoConsultaViaCEP: TMemo
        Left = 2
        Top = 15
        Width = 177
        Height = 338
        Align = alClient
        Lines.Strings = (
          'Memo1')
        TabOrder = 0
      end
    end
  end
end
