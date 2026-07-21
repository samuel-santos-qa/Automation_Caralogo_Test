# language: pt

@authenticated
Funcionalidade: Definições de measurements autenticadas

  Cenário: Consultar definições de measurements do proprietário
    Quando eu consultar as definições de measurements autenticadas
    Então devo receber status code 200
    E devo validar o contrato da lista de definições autenticadas
    E a lista de definições autenticadas não deve estar vazia
    E devo validar o contrato das definições autenticadas retornadas
    E devo validar que existe uma definição padrão autenticada
    E a resposta autenticada de definições não deve expor campos internos proibidos
