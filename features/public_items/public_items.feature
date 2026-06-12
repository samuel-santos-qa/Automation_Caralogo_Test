# language: pt

Funcionalidade: Catálogo público

  Cenário: Consultar itens públicos de um perfil existente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens
    Então devo receber status code 200
    E a resposta não deve expor campos proibidos

  Cenário: Consultar opções públicas de filtro de um perfil existente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para as opções públicas de filtro
    Então devo receber status code 200
    E a resposta não deve expor campos proibidos

  Cenário: Consultar catálogo público com item publicado
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens
    Então devo receber status code 200
    E devo validar que o catálogo público possui o item esperado
    E devo validar os dados resumidos do item público
    E a resposta não deve expor campos proibidos

  Cenário: Consultar detalhe público de um item publicado
    Dado que eu tenha um item público válido
    Quando eu fizer uma requisição GET para o detalhe público do item
    Então devo receber status code 200
    E devo validar os dados detalhados do item público
    E a resposta não deve expor campos proibidos
