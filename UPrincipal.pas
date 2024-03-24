unit UPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.Mask, Vcl.DBCtrls,
  System.StrUtils, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent;

type
  TFormPrincipal = class(TForm)
    PanelTop: TPanel;
    PanelClient: TPanel;
    GroupBoxResultadoConsulta: TGroupBox;
    PageControl: TPageControl;
    TabSheetConsultaCep: TTabSheet;
    TabSheetConsultaPorEndereco: TTabSheet;
    RadioGroupFormatoConsulta: TRadioGroup;
    BitBtnConsultar: TBitBtn;
    BitBtnLimparCampos: TBitBtn;
    Panel1: TPanel;
    DBGridCEP: TDBGrid;
    DBEditCEPPesquisa: TDBEdit;
    LabelCEP: TLabel;
    Label1: TLabel;
    DBEditLocalidadePesquisa: TDBEdit;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    MemoRetornoConsultaViaCEP: TMemo;
    Label3: TLabel;
    DBEditCEP: TDBEdit;
    Label4: TLabel;
    DBEditLogradouro: TDBEdit;
    Label5: TLabel;
    DBEditComplemento: TDBEdit;
    Label6: TLabel;
    DBEditBairro: TDBEdit;
    Label7: TLabel;
    DBEditLocalidade: TDBEdit;
    Label8: TLabel;
    DBEditUF: TDBEdit;
    DBEditLogradouroPesquisa: TDBEdit;
    Label9: TLabel;
    DBComboBoxUF: TDBComboBox;
    procedure BitBtnConsultarClick(Sender: TObject);
    procedure BitBtnLimparCamposClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

uses UConsultaCEP
   , UDm;

{$R *.dfm}

procedure TFormPrincipal.BitBtnConsultarClick(Sender: TObject);
var
  WsConsultaCEP : TConsultaCEP;
  Localidade, Logradouro : String;
begin
  try

    WsConsultaCEP := TConsultaCEP.Create;

    if PageControl.ActivePage = TabSheetConsultaCep then
    begin
      if DM.CDSPesquisaCEP.IsNull then
      begin
        MessageBox(0, 'Informe o Cep para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
        DBEditCEPPesquisa.SetFocus;
        exit;
      end;

    end
    else
    begin
      if DM.CDSPesquisaUF.IsNull then
      begin
        MessageBox(0, 'Informe a UF para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
        DBComboBoxUF.SetFocus;
        exit;
      end;
      if DM.CDSPesquisaLOCALIDADE.IsNull then
      begin
        MessageBox(0, 'Informe a Localidade/Cidade para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
        DBEditLocalidadePesquisa.SetFocus;
        exit;
      end;
      if DM.CDSPesquisaLOGRADOURO.IsNull then
      begin
        MessageBox(0, 'Informe o Logradouro para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
        DBEditLogradouroPesquisa.SetFocus;
        exit;
      end;
    end;


    DM.FDQueryCep.Close;
    DM.FDQueryCep.SQL.Clear;
    DM.FDQueryCep.SQL.Add('SELECT * ');
    DM.FDQueryCep.SQL.Add('  FROM CEP');

    if PageControl.ActivePage = TabSheetConsultaCep then
      DM.FDQueryCep.SQL.Add('WHERE CEP LIKE ' + QuotedStr('%' + DM.CDSPesquisaCEP.AsString + '%'))
    else
    begin
      DM.FDQueryCep.SQL.Add('WHERE UF = ' + QuotedStr( DM.CDSPesquisaUF.AsString ));
      DM.FDQueryCep.SQL.Add('  AND UPPER(LOCALIDADE) LIKE UPPER(' + QuotedStr('%' + DM.CDSPesquisaLOCALIDADE.AsString + '%') + ')');
      DM.FDQueryCep.SQL.Add('  AND UPPER(LOGRADOURO) LIKE UPPER(' + QuotedStr('%' + DM.CDSPesquisaLOGRADOURO.AsString + '%') + ')');
    end;
    DM.FDQueryCep.Open;
    // verifica se a consulta retornou algum registro
    if DM.FDQueryCep.IsEmpty then
    begin
      if PageControl.ActivePage = TabSheetConsultaCep then
      begin
        MemoRetornoConsultaViaCEP.Text := WsConsultaCEP.ConsultarCEP(DM.CDSPesquisaCEP.AsString,
         TFormatoRetorno(RadioGroupFormatoConsulta.ItemIndex) );
        // inseri cep na base
        DM.FDQueryCep.Insert;
        DM.FDQueryCepCODIGO.AsInteger := DM.BuscarSeqCodigoCep;
        case RadioGroupFormatoConsulta.ItemIndex of
          0: DM.JSONToFDQuery(MemoRetornoConsultaViaCEP.Text, DM.FDQueryCep);
          1: DM.XMLToFDQuery(MemoRetornoConsultaViaCEP.Text, DM.FDQueryCep);
        end;
        DM.FDQueryCep.Post;
      end
      else
      begin
        Localidade := StringReplace(DM.CDSPesquisaLOCALIDADE.AsString, ' ','+', [rfReplaceAll]);
        Logradouro := StringReplace(DM.CDSPesquisaLOGRADOURO.AsString, ' ','+', [rfReplaceAll]);
        // Consulta ViaCep
        MemoRetornoConsultaViaCEP.Text := WsConsultaCEP.ConsultarUFLocalidadeLogra(
         DM.CDSPesquisaUF.AsString,
         Localidade,
         Logradouro,
         TFormatoRetorno(RadioGroupFormatoConsulta.ItemIndex) );

        case RadioGroupFormatoConsulta.ItemIndex of
          0: DM.JSONArrayToFDQuery(MemoRetornoConsultaViaCEP.Text, DM.FDQueryCep);
          1: DM.XMLToFDQuery(MemoRetornoConsultaViaCEP.Text, DM.FDQueryCep);
        end;

      end;




    end;

  finally
     WsConsultaCEP.Free;
  end;
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
begin
  PageControl.ActivePageIndex := 0;
  BitBtnLimparCamposClick(Sender);
end;

procedure TFormPrincipal.BitBtnLimparCamposClick(Sender: TObject);
begin
  DM.CDSPesquisa.EmptyDataSet;
  DM.FDQueryCep.Close;
  MemoRetornoConsultaViaCEP.Clear;
end;

end.
