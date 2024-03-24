# ProjetoConsultaCep
Projeto consulta Cep VIACep
![Delphi Supported Versions](https://img.shields.io/badge/Delphi%20Supported%20Versions-XE%20and%20ever-blue.svg)
![Platforms](https://img.shields.io/badge/Platforms-Win32%20and%20Win64-red.svg)
![Compatibility](https://img.shields.io/badge/Compatibility-VCL,%20Firemonkey%20DataSnap%20and%20uniGUI-brightgreen.svg)

## Pré-requisitos
Para executar a aplicação deve ter instalado localmente alguma versão do firebird instalado.
O Arquivo do banco de dados deve estar em uma pasta DB/DBCONSULTACEP.fdb no mesmo local onde se encontra o executavel do projeto.

## Objetivo do Projeto
Aplicação foi criada para cumprir um desafio tecnico onde foi exigido a consulta de CEP diretamente pelo WS da ViaCep (https://viacep.com.br/)

Algumas das funcionalidades são:
Consulta via CEP ou via endereço completo(UF/CIDADE/LOGRADOURO)

Quando não localizar o endereço na base local efetuar a consulta no WS da ViaCep e salvar os dados localmente.

