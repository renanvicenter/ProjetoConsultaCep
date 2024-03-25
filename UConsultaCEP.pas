unit UConsultaCEP;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.StrUtils,
  System.Net.HttpClientComponent;

type
  TFormatoRetorno = (frJSON, frXML);

  TConsultaCEP = class
  private
    FHTTPClient: TNetHTTPClient;
    function MontarURL(const CamposPesquisa: string; Formato: TFormatoRetorno): string;
  public
    constructor Create;
    destructor Destroy; override;
    function ConsultarCEP(const CEP: string; Formato: TFormatoRetorno; out BEncontrouCep : boolean): string;
    function ConsultarUFLocalidadeLogra(const UF, Localidade, Logradouro: string; Formato: TFormatoRetorno; out BEncontrouCep : boolean): string;
    function ValidaRetornoConsultaWs(Formato: TFormatoRetorno; Resultado : string): Boolean;
  end;

implementation

{ TConsultaCEP }

constructor TConsultaCEP.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
end;

destructor TConsultaCEP.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TConsultaCEP.MontarURL(const CamposPesquisa: string; Formato: TFormatoRetorno): string;
begin
  Result := 'https://viacep.com.br/ws/' + CamposPesquisa + '/' + IfThen(Formato = frJSON, 'json', 'xml');
end;

function TConsultaCEP.ConsultarCEP(const CEP: string; Formato: TFormatoRetorno; out BEncontrouCep : boolean): string;
var
  URL: string;
  res: IHTTPResponse;
begin
  URL := MontarURL(CEP, Formato);
  try
    BEncontrouCep := False;
    res := FHTTPClient.Get(URL);
    if (Res.StatusCode = 200) and (ValidaRetornoConsultaWs(Formato, res.contentasString)) then
    begin
      BEncontrouCep := True;
      result := res.contentasString
    end;
  except
    on E: Exception do
      Result := '{"erro": "' + E.Message + '"}';
  end;
end;

function TConsultaCEP.ConsultarUFLocalidadeLogra(const UF, Localidade, Logradouro: string;
  Formato: TFormatoRetorno; out BEncontrouCep : boolean): string;
var
  URL: string;
  res: IHTTPResponse;
begin
  URL := MontarURL(UF + '/' + Localidade + '/' + Logradouro, Formato);
  try
    BEncontrouCep := False;
    res := FHTTPClient.Get(URL);
    if (Res.StatusCode = 200) and (ValidaRetornoConsultaWs(Formato, res.contentasString)) then
    begin
      BEncontrouCep := True;
      result := res.contentasString;
    end;
  except
    on E: Exception do
      Result := '{"erro": "' + E.Message + '"}';
  end;
end;

function TConsultaCEP.ValidaRetornoConsultaWs(Formato: TFormatoRetorno; Resultado : string): Boolean;
const
  retornoCepInvalidoJson = '{'#$A'  "erro": true'#$A'}';
  retornoCepInvalidoXML = '<?xml version="1.0" encoding="UTF-8"?>'#$A'<xmlcep>'#$A'  <erro>true</erro>'#$A'</xmlcep>';
begin
  if (Formato = frJson) then
    result := not (Resultado = retornoCepInvalidoJson)
  else
    result := not (Resultado = retornoCepInvalidoXML);

end;

end.

