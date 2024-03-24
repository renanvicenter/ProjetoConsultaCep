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
  private
    { Private declarations }
    ArrayCampos : TArray<string>;
  public
    { Public declarations }

    procedure JSONToFDQuery(JSON: string; DataSet: TFDQuery);
    procedure JSONArrayToFDQuery(JSON: string; DataSet: TFDQuery);
    procedure XMLToFDQuery(XML: string; DataSet: TFDQuery);

    function BuscarSeqCodigoCep: Integer;
    function RetiraCaracterEspecial(const Value: string): string;
    function FindInArray(const Value: string; const ArrayToSearch: array of string): Boolean;
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
      Exit; // Encerra o loop assim que encontrar o valor
    end;
  end;
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
    // Fechar a consulta
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
  // Criar um novo array JSON a partir da string JSON
  JSONArray := TJSONObject.ParseJSONValue(JSON) as TJSONArray;
  try
    // Iterar sobre os elementos do array JSON
    for I := 0 to JSONArray.Count - 1 do
    begin
      // inseri cep na base
      DM.FDQueryCep.Insert;
      DM.FDQueryCepCODIGO.AsInteger := DM.BuscarSeqCodigoCep;

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
  finally
    JSONArray.Free;
  end;
end;

procedure TDM.XMLToFDQuery(XML: string; DataSet: TFDQuery);
var
  XMLDocument: TXMLDocument;
  RootNode, ChildNode: IXMLNode;
  AttributeIndex: Integer;
  Field: TField;
  FieldName: string;
begin
  // Criar um novo documento XML a partir da string XML
  XMLDocument := TXMLDocument.Create(nil);
  try
    XMLDocument.LoadFromXML(XML);

    // Obter o nó raiz do documento XML
    RootNode := XMLDocument.DocumentElement;

    // Iterar sobre os nós filhos do nó raiz
    ChildNode := RootNode.ChildNodes.First;
    while Assigned(ChildNode) do
    begin
      // Verificar se o nó atual é um elemento (não um texto ou outro tipo de nó)
      if ChildNode.NodeType = ntElement then
      begin
        // Adicionar campos ao ClientDataSet para cada atributo do nó filho
        for AttributeIndex := 0 to ChildNode.AttributeNodes.Count - 1 do
        begin
          try
            FieldName := ChildNode.AttributeNodes[AttributeIndex].NodeName;
            // Adicionar um campo ao FDQuery
            if FindInArray(FieldName, ArrayCampos) then
              DataSet.FieldByName(FieldName).AsString :=
                ChildNode.AttributeNodes[AttributeIndex].NodeValue;
          except
            on e:exception do
              if (not (ContainsText(e.Message, ': Field ')) and
                (not (ContainsText(e.Message, 'not found')))) then
                ShowMessage(e.Message);
          end;

        end;
      end;

      // Avançar para o próximo nó filho
      ChildNode := ChildNode.NextSibling;
    end;
  finally
    XMLDocument.Free;
  end;
end;


end.
