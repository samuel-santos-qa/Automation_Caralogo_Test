# language: pt

@authenticated
Funcionalidade: Sugestões do catálogo autenticado

  Cenário: Sugerir um produto do catálogo a partir de dados conhecidos
    Dado que eu tenha dados conhecidos de um produto para sugestão autenticada
    Quando eu solicitar sugestões autenticadas para esse produto
    Então devo receber status code 200
    E devo validar o contrato da lista autenticada de sugestões
    E a lista autenticada de sugestões não deve estar vazia
    E devo validar o contrato das sugestões autenticadas retornadas
    E a sugestão autenticada deve incluir o produto usado na busca
    E a resposta autenticada de sugestões não deve expor campos administrativos internos
