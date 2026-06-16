# language: pt

Funcionalidade: Mídia negativa via share público

  Cenário: Consultar imagem via share com sortOrder inexistente
    Dado que eu tenha um token válido de share item configurado
    Quando eu fizer uma requisição GET para uma imagem via share com sortOrder inexistente
    Então devo receber status code 404
    E devo validar resposta genérica de mídia via share inexistente
    E a resposta não deve expor campos proibidos

  Cenário: Consultar imagem via share com sortOrder inválido textual
    Dado que eu tenha um token válido de share item configurado
    Quando eu fizer uma requisição GET para uma imagem via share com sortOrder inválido textual
    Então devo receber status code 404
    E devo validar resposta genérica de mídia via share inexistente
    E a resposta não deve expor campos proibidos

  Cenário: Consultar imagem cover via share com token revogado
    Dado que eu tenha um token revogado de share item configurado
    Quando eu fizer uma requisição GET para a imagem cover via share com token revogado
    Então devo receber status code 404
    E devo validar resposta genérica de mídia via share inexistente
    E a resposta não deve expor campos proibidos

  Cenário: Consultar imagem por sortOrder via share com token revogado
    Dado que eu tenha um token revogado de share item configurado
    Quando eu fizer uma requisição GET para a imagem por sortOrder via share com token revogado
    Então devo receber status code 404
    E devo validar resposta genérica de mídia via share inexistente
    E a resposta não deve expor campos proibidos
