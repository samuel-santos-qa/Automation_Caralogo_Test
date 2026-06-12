# language: pt

Funcionalidade: Perfil público

  Cenário: Consultar perfil público existente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para o perfil público
    Então devo receber status code 200
    E a resposta não deve expor campos proibidos
