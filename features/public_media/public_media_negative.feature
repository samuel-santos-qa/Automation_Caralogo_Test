# language: pt

Funcionalidade: Mídia pública inexistente

  Cenário: Consultar imagem pública com sortOrder inexistente
    Dado que eu tenha um item público válido
    Quando eu fizer uma requisição GET para uma imagem pública com sortOrder inexistente
    Então devo receber status code 404
    E devo validar resposta genérica de mídia pública inexistente
    E a resposta não deve expor campos proibidos

  Cenário: Consultar imagem pública com sortOrder inválido textual
    Dado que eu tenha um item público válido
    Quando eu fizer uma requisição GET para uma imagem pública com sortOrder inválido textual
    Então devo receber status code 404
    E devo validar resposta genérica de mídia pública inexistente
    E a resposta não deve expor campos proibidos

  Cenário: Consultar imagem de capa de item público inexistente
    Quando eu fizer uma requisição GET para a imagem de capa de um item público inexistente
    Então devo receber status code 404
    E devo validar resposta genérica de mídia pública inexistente
    E a resposta não deve expor campos proibidos

  Cenário: Consultar imagem por sortOrder de item público inexistente
    Quando eu fizer uma requisição GET para a imagem por sortOrder de um item público inexistente
    Então devo receber status code 404
    E devo validar resposta genérica de mídia pública inexistente
    E a resposta não deve expor campos proibidos
