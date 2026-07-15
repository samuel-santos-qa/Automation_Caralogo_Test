# language: pt

@auth
Funcionalidade: Perfil autenticado

  Cenário: Consultar perfil atual com token válido
    Dado que eu tenha autenticação QA habilitada
    Quando eu fizer uma requisição GET autenticada para o meu perfil
    Então devo receber status code 200
    E devo validar o contrato do perfil autenticado
    E a resposta autenticada não deve expor campos internos proibidos
