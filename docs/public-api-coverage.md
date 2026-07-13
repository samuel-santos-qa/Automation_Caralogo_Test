# Cobertura das APIs Públicas - Carálogo

## Objetivo

Este documento registra a cobertura endpoint-level das rotas públicas e anônimas da API Carálogo. Ele consolida o estado da automação pública antes do avanço para rotas autenticadas e serve como referência para manutenção da suíte e evolução do contrato OpenAPI.

## Escopo

O escopo atual inclui:

- endpoints públicos e anônimos;
- endpoints viewer-aware exercitados sem `Authorization`;
- share endpoints baseados em bearer URL, sem expor os tokens utilizados;
- health check público;
- Public Catalog read-only.

O escopo não inclui:

- endpoints `/me`;
- endpoints `/admin`;
- endpoints `/social`;
- endpoints autenticados de taxonomy;
- owner items e owner images;
- measurements owner;
- badges;
- share tokens owner;
- endpoint operacional `/qa/auth/token`, pois exige `x-qa-auth-secret` e será tratado separadamente como helper de QA e autenticação.

## Resumo da cobertura

- Endpoints públicos reais mapeados: **17**
- Endpoints públicos cobertos: **17**
- Cobertura endpoint-level pública: **100%**

Essa porcentagem representa cobertura por endpoint público identificado no OpenAPI atual. Ela não significa cobertura exaustiva de todos os parâmetros, combinações, permutações, contratos aninhados e casos de borda possíveis.

## Endpoints públicos cobertos

| Grupo | Método | Endpoint | Status | Arquivos/features relacionados | Observações |
| --- | --- | --- | --- | --- | --- |
| Health | GET | `/health` | Coberto | `features/health/health.feature` | Valida disponibilidade e resposta básica de saúde da API. |
| Public Profile | GET | `/@{handle}` | Coberto | `features/public_profile/public_profile.feature`<br>`features/public_negative/public_negative.feature` | Inclui perfil existente e handle inválido com erro seguro. |
| Public Items | GET | `/@{handle}/filter-options` | Coberto | `features/public_items/public_items.feature`<br>`features/public_items/public_filters.feature` | Valida opções públicas de brand, category, collection e tags. |
| Public Items | GET | `/@{handle}/items` | Coberto | `features/public_items/public_items.feature`<br>`features/public_items/public_filters.feature`<br>`features/public_items/public_measurement_filters.feature`<br>`features/public_items/public_pagination.feature`<br>`features/public_items/public_pagination_out_of_range.feature`<br>`features/public_items/public_sorting.feature`<br>`features/public_items/public_pagination_sorting.feature`<br>`features/public_items/item_visibility_public_catalog.feature`<br>`features/public_items/field_visibility.feature` | Cobre catálogo, filtros, measurements, paginação, ordenação e regras de visibilidade. |
| Public Items | GET | `/@{handle}/items/{slugWithPublicId}` | Coberto | `features/public_items/public_items.feature`<br>`features/public_items/field_visibility.feature` | Valida detalhe público, contrato e field visibility. |
| Public Media | GET | `/@{handle}/items/{slugWithPublicId}/images/cover` | Coberto | `features/public_media/public_media.feature`<br>`features/public_media/public_media_negative.feature` | Inclui mídia válida e respostas seguras para recursos inexistentes. |
| Public Media | GET | `/@{handle}/items/{slugWithPublicId}/images/{sortOrder}` | Coberto | `features/public_media/public_media.feature`<br>`features/public_media/public_media_negative.feature` | Inclui sortOrder válido, inexistente e textual inválido. |
| Measurements | GET | `/@{handle}/measurement-definitions` | Coberto | `features/public_measurements/public_measurement_definitions.feature` | Cobre acesso anônimo, handle inexistente e `Authorization` inválido em rota viewer-aware. |
| Shared Items | GET | `/share/items/{token}` | Coberto | `features/shared_items/share_item.feature`<br>`features/shared_items/shared_items_negative.feature` | Inclui share válido, inválido e revogado sem expor valores de tokens. |
| Shared Items | GET | `/share/items/{token}/images/cover` | Coberto | `features/shared_items/share_item.feature`<br>`features/shared_items/share_media_negative.feature` | Cobre imagem válida e negação segura para share revogado. |
| Shared Items | GET | `/share/items/{token}/images/{sortOrder}` | Coberto | `features/shared_items/share_item.feature`<br>`features/shared_items/share_media_negative.feature` | Cobre imagem válida, sortOrder inexistente e share revogado. |
| Public Catalog | GET | `/public/catalog/brands` | Coberto | `features/public_catalog/public_catalog_basic.feature` | Lista e busca marcas com descoberta dinâmica de dados. |
| Public Catalog | GET | `/public/catalog/products` | Coberto | `features/public_catalog/public_catalog_basic.feature` | Lista produtos e filtra dinamicamente por `brandSlug`. |
| Public Catalog | GET | `/public/catalog/suggest` | Coberto | `features/public_catalog/public_catalog_basic.feature` | Valida sugestões e associação com produto descoberto pela API. |
| Public Catalog | GET | `/public/catalog/rankings` | Coberto | `features/public_catalog/public_catalog_advanced.feature` | Cobre contrato de rankings e métrica específica `totalLength`. |
| Public Catalog | GET | `/public/catalog/products/by-id/{productId}` | Coberto | `features/public_catalog/public_catalog_advanced.feature` | Inclui detalhe dinâmico e produto inexistente. |
| Public Catalog | GET | `/public/catalog/products/by-id/{productId}/variants/{sizeNormalized}` | Coberto | `features/public_catalog/public_catalog_advanced.feature` | Inclui variante descoberta dinamicamente e size inexistente. |

## Tipos de validação já cobertos

- status code esperado;
- contrato mínimo de resposta;
- presença de campos obrigatórios;
- ausência de campos proibidos e sensíveis;
- filtros públicos;
- paginação válida;
- paginação inválida;
- paginação fora do range;
- ordenação;
- paginação combinada com ordenação;
- filtros por measurement;
- field visibility;
- itens private e unlisted fora do catálogo público;
- mídia pública válida;
- mídia pública inexistente;
- share token válido;
- share token inválido;
- share token revogado;
- Public Catalog básico e avançado;
- `Authorization` inválido em measurement definitions viewer-aware.

## Campos sensíveis validados

A suíte possui validação recursiva para detectar campos proibidos em Hashes, Arrays e respostas textuais. Essa proteção é reutilizada em respostas públicas de sucesso e de erro.

Exemplos de campos monitorados:

- `privateNotes`;
- `purchasePrice`;
- `purchaseCurrency`;
- `purchaseDate`;
- `purchaseVendor`;
- `purchaseLink`;
- `purchaseNotes`;
- `authProviderId`;
- `profileId`;
- `tokenHash`;
- `storageProvider`;
- `bucket`;
- `storageKey`;
- `password`;
- `accessToken`;
- `refreshToken`;
- `authorization`;
- `cookie`.

A massa também contempla variações equivalentes em `snake_case` quando aplicável.

## Limitações conhecidas

Ainda podem ser ampliados no futuro:

- validação mais forte de tipos em todos os contratos;
- mais combinações de filtros no Public Catalog;
- `Authorization` inválido em todas as rotas públicas viewer-aware;
- canonicalização e redirect `308` de slug antigo;
- cenários de redirect `302` quando o modo `signed_redirect` estiver ativo;
- validações mais profundas de schemas aninhados;
- combinações adicionais de paginação, ordenação e filtros avançados.

## Próxima fase

Com a cobertura pública endpoint-level fechada, a próxima fase recomendada é iniciar as rotas autenticadas, começando por:

- obtenção de token QA por helper operacional separado;
- `/me/profile`;
- taxonomies owner-scoped;
- owner items;
- owner images;
- share tokens owner;
- social;
- admin catalog, quando houver permissão apropriada.

## Como atualizar este documento

- Sempre que um novo endpoint público for adicionado ao Swagger/OpenAPI, atualizar a tabela de endpoints.
- Sempre que uma nova feature pública for criada, relacionar o arquivo na coluna correspondente.
- Recalcular a quantidade de endpoints mapeados e cobertos.
- Revisar as limitações conhecidas conforme novos cenários forem implementados.
- Manter a distinção entre cobertura endpoint-level e cobertura exaustiva de parâmetros e casos de borda.
