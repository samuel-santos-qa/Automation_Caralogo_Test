# Automation Caralogo Test

## Sobre o projeto

Este projeto é uma suíte de automação backend para validar endpoints públicos da API Caralogo em ambiente de staging.

O foco da suíte é garantir comportamento esperado, contrato de resposta, segurança de dados públicos, visibilidade de campos e consistência do catálogo público, sem uso de autenticação ou headers sensíveis.

## Tecnologias utilizadas

- Ruby
- Cucumber
- HTTParty
- RSpec
- YAML
- Git/GitHub

## Objetivo da suíte

A suíte valida os principais comportamentos públicos e seguros da API, incluindo:

- health check;
- rotas protegidas sem token;
- perfil público;
- catálogo público;
- filtros públicos;
- filtros por measurements;
- ordenação;
- paginação;
- paginação fora do range;
- paginação combinada com ordenação;
- mídia pública;
- mídia pública negativa;
- field visibility;
- itens private/unlisted fora do catálogo público;
- share link válido;
- share link revogado;
- share token inválido;
- mídia negativa via share;
- ausência de campos proibidos em respostas publicas.

## Segurança e dados sensíveis

Os tokens de share usados nesta suíte estão centralizados em `config/default_data.yaml` e pertencem exclusivamente ao ambiente de staging.

Esses tokens não são tokens de autenticação, cookies, JWTs, API keys ou credenciais reais. O token válido é usado apenas para validar acesso a um item compartilhado controlado em staging, e o token revogado é usado para validar retorno seguro `404`.

O arquivo `.env` continua ignorado pelo Git para proteger eventuais configurações locais, mas no estado atual da suíte não é necessário exportar variáveis de ambiente para rodar os testes.

Nenhum token de autenticação, cookie, JWT, API key ou credencial real deve ser versionado.

## Como configurar o projeto

Instale as dependências:

```bash
bundle install
```

Os dados de teste, incluindo tokens de share de staging, ficam centralizados em `config/default_data.yaml`.

## Como rodar os testes

Rodar a suíte completa:

```bash
bundle exec cucumber
```

Rodar uma feature especifica:

```bash
bundle exec cucumber features/public_items/public_filters.feature
```

## Estrutura do projeto

```text
config/
  default_data.yaml

features/
  auth/
  health/
  public_items/
  public_media/
  public_negative/
  public_profile/
  shared_items/
  step_definitions/
  support/

services/
  caralogo_service.rb
```

## Status atual da suíte

última execução local:

```text
73 scenarios passed
335 steps passed
```

## Boas praticas aplicadas

- massa de teste centralizada em YAML;
- steps reutilizáveis;
- validação de status code;
- validação de contrato JSON;
- validação de ausência de campos proibidos;
- cenários positivos e negativos;
- proteção contra vazamento de dados privados;
- separação entre massa pública de catálogo e massa de share.

## Observação

Este e um projeto de estudo e portifólio em ambiente de staging, sem uso de credenciais de produção.

Nenhum token real, cookie, secret ou header de autorização deve ser versionado neste repositório.
