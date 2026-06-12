# language: pt

Funcionalidade: Share público de item

  Cenário: Consultar item compartilhado com token válido
    Dado que eu tenha um token válido de share item configurado
    Quando eu fizer uma requisição GET para o item compartilhado
    Então devo receber status code 200
    E devo validar os dados públicos do item compartilhado
    E a resposta não deve expor campos proibidos

  Cenário: Consultar imagem cover de item compartilhado com token válido
    Dado que eu tenha um token válido de share item configurado
    Quando eu fizer uma requisição GET para a imagem cover do item compartilhado
    Então devo receber status code 200
    E devo validar que a resposta contém uma imagem

  Cenário: Consultar imagem por sortOrder de item compartilhado com token válido
    Dado que eu tenha um token válido de share item configurado
    Quando eu fizer uma requisição GET para a imagem de sortOrder 0 do item compartilhado
    Então devo receber status code 200
    E devo validar que a resposta contém uma imagem

  Cenário: Consultar item compartilhado com token revogado
    Dado que eu tenha um token revogado de share item configurado
    Quando eu fizer uma requisição GET para o item compartilhado revogado
    Então devo receber status code 404
    E a resposta não deve expor campos proibidos
