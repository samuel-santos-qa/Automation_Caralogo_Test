# language: pt

Funcionalidade: Public Catalog avançado

  Cenário: Listar rankings públicos do catálogo de referência
    Quando eu fizer uma requisição GET para os rankings públicos do catálogo
    Então devo receber status code 200
    E devo validar o contrato da lista pública de rankings do catálogo
    E a resposta não deve expor campos proibidos

  Cenário: Listar rankings públicos com métrica específica
    Quando eu fizer uma requisição GET para rankings públicos usando a métrica totalLength
    Então devo receber status code 200
    E devo validar que os rankings retornados usam a métrica esperada
    E a resposta não deve expor campos proibidos

  Cenário: Consultar detalhe público de produto por ID
    Dado que eu tenha um produto público do catálogo de referência
    Quando eu fizer uma requisição GET para o detalhe público desse produto por ID
    Então devo receber status code 200
    E devo validar o contrato do detalhe público de produto do catálogo
    E devo validar que o detalhe retornado pertence ao produto esperado
    E a resposta não deve expor campos proibidos

  Cenário: Consultar detalhe público de produto por ID inexistente
    Quando eu fizer uma requisição GET para detalhe público de produto com ID inexistente
    Então devo receber status code 404
    E a resposta não deve expor campos proibidos

  Cenário: Consultar detalhe público de variante por productId e sizeNormalized
    Dado que eu tenha um produto público do catálogo de referência com variante
    Quando eu fizer uma requisição GET para o detalhe público da variante desse produto
    Então devo receber status code 200
    E devo validar o contrato do detalhe público de variante do catálogo
    E devo validar que a variante retornada pertence à size esperada
    E a resposta não deve expor campos proibidos

  Cenário: Consultar detalhe público de variante inexistente
    Dado que eu tenha um produto público do catálogo de referência
    Quando eu fizer uma requisição GET para uma variante pública inexistente desse produto
    Então devo receber status code 404
    E a resposta não deve expor campos proibidos
