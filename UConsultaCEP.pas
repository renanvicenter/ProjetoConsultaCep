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
const
  retornoCepInvalido = '{'#$A'  "erro": true'#$A'}';
var
  URL: string;
  res: IHTTPResponse;
begin
  URL := MontarURL(CEP, Formato);
  try
    BEncontrouCep := True;
    res := FHTTPClient.Get(URL);
    if (Res.StatusCode = 200) and (not (res.contentasString = retornoCepInvalido)) then
      result := res.contentasString
    else
      BEncontrouCep := False;
  except
    on E: Exception do
      Result := '{"erro": "' + E.Message + '"}';
  end;
end;

function TConsultaCEP.ConsultarUFLocalidadeLogra(const UF, Localidade, Logradouro: string; Formato: TFormatoRetorno; out BEncontrouCep : boolean): string;
const
  retornoCepInvalido = '{'#$A'  "erro": true'#$A'}';
var
  URL: string;
  res: IHTTPResponse;
begin
  URL := MontarURL(UF + '/' + Localidade + '/' + Logradouro, Formato);
  try
    BEncontrouCep := True;
    res := FHTTPClient.Get(URL);
    if (Res.StatusCode = 200) and (not (res.contentasString = retornoCepInvalido)) then
      result := res.contentasString
    else
      BEncontrouCep := False;
  except
    on E: Exception do
      Result := '{"erro": "' + E.Message + '"}';
  end;
end;

end.

