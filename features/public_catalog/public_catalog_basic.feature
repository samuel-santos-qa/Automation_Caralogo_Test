# language: pt

Funcionalidade: Public Catalog básico

  Cenário: Listar marcas públicas do catálogo de referência
    Quando eu fizer uma requisição GET para as marcas públicas do catálogo
    Então devo receber status code 200
    E devo validar o contrato da lista pública de marcas do catálogo
    E a resposta não deve expor campos proibidos

  Cenário: Buscar marcas públicas do catálogo usando search
    Dado que eu tenha uma marca pública do catálogo de referência
    Quando eu buscar marcas públicas do catálogo usando parte do nome dessa marca
    Então devo receber status code 200
    E devo validar que a busca retorna a marca esperada
    E a resposta não deve expor campos proibidos

  Cenário: Listar produtos públicos do catálogo de referência
    Quando eu fizer uma requisição GET para os produtos públicos do catálogo
    Então devo receber status code 200
    E devo validar o contrato da lista pública de produtos do catálogo
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar produtos públicos do catálogo por brandSlug
    Dado que eu tenha um produto público do catálogo de referência
    Quando eu filtrar produtos públicos do catálogo pelo brandSlug desse produto
    Então devo receber status code 200
    E devo validar que os produtos retornados pertencem à marca esperada
    E a resposta não deve expor campos proibidos

  Cenário: Sugerir produtos públicos do catálogo
    Dado que eu tenha um produto público do catálogo de referência
    Quando eu pedir sugestões públicas do catálogo usando o nome desse produto
    Então devo receber status code 200
    E devo validar o contrato das sugestões públicas do catálogo
    E devo validar que a sugestão retorna o produto esperado
    E a resposta não deve expor campos proibidos
