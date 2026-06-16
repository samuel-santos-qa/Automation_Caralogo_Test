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

Tokens reais não são versionados neste projeto.

O arquivo `.env` fica ignorado pelo Git, e o arquivo `.env.example` existe apenas como modelo para configuração local.

As variáveis de ambiente usadas nos testes de share são:

- `CARALOGO_SHARE_ITEM_TOKEN_VALIDO`
- `CARALOGO_SHARE_ITEM_TOKEN_REVOGADO`

Esses valores devem ser configurados localmente e nunca devem ser compartilhados, expostos em logs ou commitados.

## Como configurar o projeto

Instale as dependências:

```bash
bundle install
```

Configure as variáveis de ambiente no Git Bash:

```bash
export CARALOGO_SHARE_ITEM_TOKEN_VALIDO="seu_token_valido"
export CARALOGO_SHARE_ITEM_TOKEN_REVOGADO="seu_token_revogado"
```

Os tokens devem ser gerados no ambiente de staging e utilizados somente para execução local dos testes de share.

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
- uso de variáveis de ambiente para dados sensíveis.

## Observação

Este e um projeto de estudo e portifólio em ambiente de staging, sem uso de credenciais de produção.

Nenhum token real, cookie, secret ou header de autorização deve ser versionado neste repositório.
