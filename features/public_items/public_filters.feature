# language: pt

Funcionalidade: Filtros públicos do catálogo

  Cenário: Validar opções públicas de filtro
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para as opções públicas de filtro
    Então devo receber status code 200
    E devo validar que as opções públicas de filtro possuem brand, category, collection e tags esperadas
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por brandSlug válido
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por brandSlug válido
    Então devo receber status code 200
    E devo validar que todos os itens retornados pertencem à brand esperada
    E devo validar que o catálogo público possui o item esperado
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por brandSlug inexistente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por brandSlug inexistente
    Então devo receber status code 200
    E devo validar que o catálogo público retornou vazio
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por categorySlug válido
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por categorySlug válido
    Então devo receber status code 200
    E devo validar que o catálogo público possui o item esperado
    E devo validar que todos os itens retornados pertencem à category esperada quando a category estiver presente na resposta
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por categorySlug inexistente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por categorySlug inexistente
    Então devo receber status code 200
    E devo validar que o catálogo público retornou vazio
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por collectionSlug válido
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por collectionSlug válido
    Então devo receber status code 200
    E devo validar que o catálogo público possui o item esperado
    E devo validar que todos os itens retornados pertencem à collection esperada quando a collection estiver presente na resposta
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por collectionSlug inexistente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por collectionSlug inexistente
    Então devo receber status code 200
    E devo validar que o catálogo público retornou vazio
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por tagSlugs válido
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por tagSlugs válido
    Então devo receber status code 200
    E devo validar que o catálogo público possui o item esperado
    E devo validar que todos os itens retornados possuem a tag esperada quando tags estiverem presentes na resposta
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por múltiplos tagSlugs válidos
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por múltiplos tagSlugs válidos
    Então devo receber status code 200
    E devo validar que o catálogo público possui o item esperado
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por tagSlugs inexistente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por tagSlugs inexistente
    Então devo receber status code 200
    E devo validar que o catálogo público retornou vazio
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público combinando filtros válidos
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens combinando filtros válidos
    Então devo receber status code 200
    E devo validar que o catálogo público possui o item esperado
    E devo validar que todos os itens retornados pertencem à brand esperada
    E a resposta não deve expor campos proibidos
