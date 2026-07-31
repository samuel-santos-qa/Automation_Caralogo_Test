# language: pt

@authenticated
Funcionalidade: Marcas do catálogo autenticado

  Cenário: Listar marcas do catálogo de referência
    Quando eu consultar as marcas do catálogo autenticado
    Então devo receber status code 200
    E devo validar o contrato da lista autenticada de marcas
    E a lista autenticada de marcas não deve estar vazia
    E devo validar o contrato das marcas autenticadas retornadas
    E a resposta autenticada de marcas não deve expor campos administrativos internos

  Cenário: Listar somente marcas com produtos ordenadas por nome
    Quando eu consultar as marcas autenticadas com produtos ordenadas por nome
    Então devo receber status code 200
    E devo validar o contrato da lista autenticada de marcas
    E a lista autenticada de marcas não deve estar vazia
    E devo validar o contrato das marcas autenticadas retornadas
    E todas as marcas autenticadas retornadas devem possuir produtos
    E as marcas autenticadas retornadas devem estar ordenadas por nome
    E a resposta autenticada de marcas não deve expor campos administrativos internos
