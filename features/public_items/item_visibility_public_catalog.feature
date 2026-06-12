# language: pt

Funcionalidade: Visibilidade de itens no catálogo público

  Cenário: Itens private e unlisted não devem aparecer na lista pública
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens
    Então devo receber status code 200
    E devo validar que itens private e unlisted não aparecem no resultado público
    E a resposta não deve expor campos proibidos

  Cenário: Itens private e unlisted não devem aparecer filtrando por brandSlug
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por brandSlug válido
    Então devo receber status code 200
    E devo validar que itens private e unlisted não aparecem no resultado público
    E a resposta não deve expor campos proibidos

  Cenário: Itens private e unlisted não devem aparecer filtrando por categorySlug
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por categorySlug válido
    Então devo receber status code 200
    E devo validar que itens private e unlisted não aparecem no resultado público
    E a resposta não deve expor campos proibidos

  Cenário: Itens private e unlisted não devem aparecer filtrando por collectionSlug
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por collectionSlug válido
    Então devo receber status code 200
    E devo validar que itens private e unlisted não aparecem no resultado público
    E a resposta não deve expor campos proibidos

  Cenário: Itens private e unlisted não devem aparecer filtrando por tagSlugs
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por tagSlugs válido
    Então devo receber status code 200
    E devo validar que itens private e unlisted não aparecem no resultado público
    E a resposta não deve expor campos proibidos
