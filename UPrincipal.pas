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
    function ValidaConsulta: Boolean;
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

function TFormPrincipal.ValidaConsulta: Boolean;
begin
  if PageControl.ActivePage = TabSheetConsultaCep then
  begin
    if DM.CDSPesquisaCEP.IsNull then
    begin
      MessageBox(0, 'Informe o Cep para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
      DBEditCEPPesquisa.SetFocus;
      result := False;
      exit;
    end;

  end
  else
  begin
    if DM.CDSPesquisaUF.IsNull then
    begin
      MessageBox(0, 'Informe a UF para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
      DBComboBoxUF.SetFocus;
      result := False;
      exit;
    end;
    if DM.CDSPesquisaLOCALIDADE.IsNull then
    begin
      MessageBox(0, 'Informe a Localidade/Cidade para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
      DBEditLocalidadePesquisa.SetFocus;
      result := False;
      exit;
    end;
    if DM.CDSPesquisaLOGRADOURO.IsNull then
    begin
      MessageBox(0, 'Informe o Logradouro para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
      DBEditLogradouroPesquisa.SetFocus;
      result := False;
      exit;
    end;

    if Length(DM.CDSPesquisaLOCALIDADE.AsString) < 3 then
    begin
      MessageBox(0, 'Informe pelo menos 3 caracteres na Localidade/Cidade para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
      DBEditLocalidadePesquisa.SetFocus;
      result := False;
      exit;
    end;
    if Length(DM.CDSPesquisaLOGRADOURO.AsString) < 3 then
    begin
      MessageBox(0, 'Informe pelo menos 3 caracteres no Logradouro para efetuar a consulta.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
      DBEditLogradouroPesquisa.SetFocus;
      result := False;
      exit;
    end;
  end;
  result := True;
end;

procedure TFormPrincipal.BitBtnConsultarClick(Sender: TObject);
var
  WsConsultaCEP : TConsultaCEP;
  Localidade, Logradouro : String;
  BConsultaViaCep, BEncontrouCepBase, BEncontrouCepWS : Boolean;
begin
  try
    WsConsultaCEP := TConsultaCEP.Create;

    if not ValidaConsulta then
      exit;

    BConsultaViaCep := True;
    BEncontrouCepBase := DM.BuscarEndereco(TTipoConsulta(PageControl.ActivePageIndex));

    if BEncontrouCepBase then
    begin
      BConsultaViaCep := (MessageBox(0, 'Foram encontrados dados deste endereço na base local. '+
        #13+#10+'Deseja efetuar uma nova consulta atualizando as informações do Endereço existente?',
        'Confirmação', MB_ICONQUESTION or MB_YESNO or MB_APPLMODAL) = idYes);
    end;

    // Se variavel True entao executa a consulta no ws ViaCep e atualiza base local
    if BConsultaViaCep then
    begin
      if PageControl.ActivePage = TabSheetConsultaCep then
      begin
        MemoRetornoConsultaViaCEP.Text := WsConsultaCEP.ConsultarCEP(DM.CDSPesquisaCEP.AsString,
         TFormatoRetorno(RadioGroupFormatoConsulta.ItemIndex), BEncontrouCepWS );

        if BEncontrouCepWS then
        begin
          // inseri cep na base
          if BEncontrouCepBase then
            DM.FDQueryCep.Edit
          else
          begin
            DM.FDQueryCep.Insert;
          end;

          case RadioGroupFormatoConsulta.ItemIndex of
            0: DM.JSONToFDQuery(MemoRetornoConsultaViaCEP.Text, DM.FDQueryCep);
            1: DM.XMLToFDQuery(MemoRetornoConsultaViaCEP.Text, DM.FDQueryCep);
          end;
          DM.FDQueryCep.Post;
        end
        else
        begin
          MessageBox(0, 'Não foram encontrados dados referente ao CEP informado.'+#13+#10+'Verifique e tente novamente.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
          DBEditCEPPesquisa.SetFocus;
          exit;
        end;
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
         TFormatoRetorno(RadioGroupFormatoConsulta.ItemIndex), BEncontrouCepWS );

        if BEncontrouCepWS then
        begin
          case RadioGroupFormatoConsulta.ItemIndex of
            0: DM.JSONArrayToFDQuery(MemoRetornoConsultaViaCEP.Text, DM.FDQueryCep);
            1: DM.XMLArrayToFDQuery(MemoRetornoConsultaViaCEP.Text, DM.FDQueryCep);
          end;
        end
        else
        begin
          MessageBox(0, 'Não foram encontrados dados referente ao Endereço informado.'+#13+#10+'Verifique e tente novamente.', 'Atenção', MB_ICONWARNING or MB_OK or MB_APPLMODAL);
          DBComboBoxUF.SetFocus;
          exit;
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
