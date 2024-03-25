unit UDm;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Datasnap.DBClient, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, Vcl.Controls, Vcl.Forms, System.JSON, Vcl.Dialogs,
  System.StrUtils, Xml.XMLDoc, Xml.XMLIntf, System.Generics.Collections,
  System.RegularExpressions;

type
  TTipoConsulta = (tcCEP, tcCompleto);
  TDM = class(TDataModule)
    FDConnection: TFDConnection;
    FDTransaction: TFDTransaction;
    FDQuery1: TFDQuery;
    DS_CDSPesquisa: TDataSource;
    CDSPesquisa: TClientDataSet;
    CDSPesquisaCEP: TStringField;
    CDSPesquisaLOGRADOURO: TStringField;
    DS_QueryCep: TDataSource;
    FDQueryCep: TFDQuery;
    FDQueryCepCODIGO: TIntegerField;
    FDQueryCepCEP: TStringField;
    FDQueryCepLOGRADOURO: TStringField;
    FDQueryCepCOMPLEMENTO: TStringField;
    FDQueryCepBAIRRO: TStringField;
    FDQueryCepLOCALIDADE: TStringField;
    FDQueryCepUF: TStringField;
    FDQueryAux: TFDQuery;
    CDSPesquisaLOCALIDADE: TStringField;
    CDSPesquisaUF: TStringField;
    procedure DataModuleCreate(Sender: TObject);
    procedure FDQueryCepBeforePost(DataSet: TDataSet);
    procedure FDQueryCepAfterInsert(DataSet: TDataSet);
  private
    { Private declarations }
    ArrayCampos : TArray<string>;
  public
    { Public declarations }

    procedure JSONToFDQuery(JSON: string; DataSet: TFDQuery);
    procedure JSONArrayToFDQuery(JSON: string; DataSet: TFDQuery);
    procedure XMLToFDQuery(XML: string; DataSet: TFDQuery);
    procedure XMLArrayToFDQuery(XML: string; DataSet: TFDQuery);

    function BuscarSeqCodigoCep: Integer;
    function RetiraCaracterEspecial(const Value: string): string;
    function FindInArray(const Value: string; const ArrayToSearch: array of string): Boolean;
    function BuscarEndereco(TipoConsulta : TTipoConsulta): Boolean;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TDM.RetiraCaracterEspecial(const Value: string): string;
begin
  Result := TRegEx.Replace(Value, '[^\w\s]', '', [roIgnoreCase]);
end;

procedure TDM.FDQueryCepAfterInsert(DataSet: TDataSet);
begin
  FDQueryCepCODIGO.AsInteger := BuscarSeqCodigoCep;
end;

procedure TDM.FDQueryCepBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('CEP').AsString := RetiraCaracterEspecial(DataSet.FieldByName('CEP').AsString);
end;

function TDM.FindInArray(const Value: string; const ArrayToSearch: array of string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(ArrayToSearch) to High(ArrayToSearch) do
  begin
    if ArrayToSearch[I] = Value then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TDM.BuscarEndereco(TipoConsulta : TTipoConsulta): Boolean;
begin
  if not FDConnection.Connected then
  begin
    result := False;
    exit;
  end;

  FDQueryCep.Close;
  FDQueryCep.SQL.Clear;
  FDQueryCep.SQL.Add('SELECT * ');
  FDQueryCep.SQL.Add('  FROM CEP');

  if TipoConsulta = tcCep then
    FDQueryCep.SQL.Add('WHERE CEP LIKE ' + QuotedStr('%' + CDSPesquisaCEP.AsString + '%'))
  else
  begin
    FDQueryCep.SQL.Add('WHERE UF = ' + QuotedStr( CDSPesquisaUF.AsString ));
    FDQueryCep.SQL.Add('  AND UPPER(LOCALIDADE) LIKE UPPER(' + QuotedStr('%' + CDSPesquisaLOCALIDADE.AsString + '%') + ')');
    FDQueryCep.SQL.Add('  AND UPPER(LOGRADOURO) LIKE UPPER(' + QuotedStr('%' + CDSPesquisaLOGRADOURO.AsString + '%') + ')');
  end;
  FDQueryCep.Open;

  result := not FDQueryCep.IsEmpty;
end;

function TDM.BuscarSeqCodigoCep: Integer;
begin
  try
    FDQueryAux.Close;
    FDQueryAux.SQL.Clear;
    FDQueryAux.SQL.Add('SELECT GEN_ID( SEQ_CODIGO_CEP, 1) AS SEQ_CODIGO_CEP FROM RDB$DATABASE ');
    FDQueryAux.Open;

    Result := FDQueryAux.FieldByName('SEQ_CODIGO_CEP').AsInteger;
  finally
    FDQueryAux.Close;
  end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  try
    ArrayCampos := TArray<string>.Create('cep', 'logradouro', 'complemento', 'bairro', 'localidade', 'uf');

    CDSPesquisa.CreateDataSet;
    CDSPesquisa.EmptyDataSet;
    CDSPesquisa.Append;

    FDConnection.Connected       := False;
    FDConnection.Params.Database := ExtractFilePath(Application.ExeName) + '\DB\DBCONSULTACEP.fdb';
    FDConnection.Params.UserName := 'SYSDBA';
    FDConnection.Params.Password := 'masterkey';
    FDConnection.Connected       := True;

    if FDConnection.Connected then
      FDQueryCep.Open;
  except

  end;
end;

procedure TDM.JSONToFDQuery(JSON: string; DataSet: TFDQuery);
var
  JSONObject: TJSONObject;
  JSONPair: TJSONPair;
  FieldName: string;
  FieldValue: TJSONValue;
begin
  // Criar um novo objeto JSON a partir da string JSON
  JSONObject := TJSONObject.ParseJSONValue(JSON) as TJSONObject;
  try
    // Iterar sobre os pares de chave/valor no objeto JSON
    for JSONPair in JSONObject do
    begin
      try
        // Obter o nome e o valor do campo
        FieldName := JSONPair.JsonString.Value;
        FieldValue := JSONPair.JsonValue;
        // Adicionar um campo ao FDQuery
        if FindInArray(FieldName, ArrayCampos) then
          DataSet.FieldByName(FieldName).AsString := FieldValue.Value;
      except
        on e:exception do
          if (not (ContainsText(e.Message, ': Field ')) and
            (not (ContainsText(e.Message, 'not found')))) then
            ShowMessage(e.Message);
      end;
    end;
  finally
    JSONObject.Free;
  end;
end;

procedure TDM.JSONArrayToFDQuery(JSON: string; DataSet: TFDQuery);
var
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  JSONValue: TJSONValue;
  JSONPair: TJSONPair;
  I: Integer;
  FieldName: string;
begin
  if not DM.FDConnection.Connected then
    exit;

  // Criar um novo array JSON a partir da string JSON
  JSONArray := TJSONObject.ParseJSONValue(JSON) as TJSONArray;
  // Iterar sobre os elementos do array JSON
  for I := 0 to JSONArray.Count - 1 do
  begin
    // inseri cep na base
    DM.FDQueryCep.Insert;

    JSONObject := JSONArray.Items[I] as TJSONObject;
    try
      // Iterar sobre os pares de chave/valor no objeto JSON
      for JSONPair in JSONObject do
      begin
        try
          // Obter o nome e o valor do campo
          FieldName := JSONPair.JsonString.Value;
          JSONValue := JSONPair.JsonValue;
          // Adicionar um campo ao FDQuery
          if FindInArray(FieldName, ArrayCampos) then
          begin
            // Se o campo existir no FDQuery, atribua o valor correspondente
            if DataSet.FindField(FieldName) <> nil then
            begin
              DataSet.FieldByName(FieldName).AsString := JSONValue.Value;
            end;
          end;
        except
          on E: Exception do
          begin
            if (not (ContainsText(E.Message, ': Field ')) and
              (not (ContainsText(E.Message, 'not found')))) then
            begin
              ShowMessage(E.Message);
            end;
          end;
        end;
      end;
    finally
      JSONObject.Free;
    end;
    DM.FDQueryCep.Post;
  end;
end;

procedure TDM.XMLToFDQuery(XML: string; DataSet: TFDQuery);
var
  XMLDocument: IXMLDocument;
  RootNode, ChildNode: IXMLNode;
  FieldName: string;
  AttributeIndex : integer;
begin
  // Criar um novo documento XML a partir da string XML
  XMLDocument := TXMLDocument.Create(nil);
  try
    XMLDocument.LoadFromXML(XML);

    // Le os dados contido nó principal
    with XMLDocument.DocumentElement do
    begin

      for AttributeIndex := 0 to ChildNodes.Count - 1 do
      begin
        try
          FieldName := ChildNodes.Nodes[AttributeIndex].NodeName;
          // Adicionar um campo ao FDQuery
          if FindInArray(FieldName, ArrayCampos) then
            DataSet.FieldByName(FieldName).AsString :=
              ChildNodes.Nodes[AttributeIndex].NodeValue;
        except
          on e:exception do
            if (not (ContainsText(e.Message, ': Field ')) and
              (not (ContainsText(e.Message, 'not found')))) then
              ShowMessage(e.Message);
        end;
      end;
    end;

  finally
    XMLDocument := nil; // Liberar a interface do documento XML
  end;
end;

procedure TDM.XMLArrayToFDQuery(XML: string; DataSet: TFDQuery);
var
  XMLDocument: IXMLDocument;
  RootNode, EnderecosNode, EnderecoNode: IXMLNode;
  AttributeNode: IXMLNode;
  i: Integer;
begin
  if not DM.FDConnection.Connected then
    exit;
  // Criar um novo documento XML a partir da string XML
  XMLDocument := TXMLDocument.Create(nil);
  try
    XMLDocument.LoadFromXML(XML);

    // Obter o nó raiz do documento XML
    RootNode := XMLDocument.DocumentElement;

    // Localizar o nó "enderecos"
    EnderecosNode := RootNode.ChildNodes.FindNode('enderecos');
    if Assigned(EnderecosNode) then
    begin
      // Iterar sobre os nós "endereco" dentro de "enderecos"
      EnderecoNode := EnderecosNode.ChildNodes.First;
      while Assigned(EnderecoNode) do
      begin
        // inseri cep na base
        DM.FDQueryCep.Insert;

        // Adicionar campos ao FDQuery para cada nó filho do nó "endereco"
        for i := 0 to EnderecoNode.ChildNodes.Count - 1 do
        begin
          AttributeNode := EnderecoNode.ChildNodes[i];
          try
            // Adicionar um campo ao FDQuery
            if FindInArray(AttributeNode.NodeName, ArrayCampos) then
              DataSet.FieldByName(AttributeNode.NodeName).AsString := AttributeNode.Text;
          except
            on e: Exception do
              if (not (ContainsText(e.Message, ': Field ')) and
                (not (ContainsText(e.Message, 'not found')))) then
                ShowMessage(e.Message);
          end;
        end;

        // Avançar para o próximo nó "endereco"
        EnderecoNode := EnderecoNode.NextSibling;
        DM.FDQueryCep.Post;
      end;
    end;
  finally
    XMLDocument := nil;
  end;
end;


end.
