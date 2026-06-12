# language: pt

Funcionalidade: Mídia pública de item

  Cenário: Consultar imagem pública de capa de um item publicado
    Dado que eu tenha um item público válido
    Quando eu fizer uma requisição GET para a imagem pública de capa
    Então devo receber status code 200
    E a resposta deve ser uma imagem

  Cenário: Consultar imagem pública por ordem de um item publicado
    Dado que eu tenha um item público válido
    Quando eu fizer uma requisição GET para a imagem pública de ordem 0
    Então devo receber status code 200
    E a resposta deve ser uma imagem
