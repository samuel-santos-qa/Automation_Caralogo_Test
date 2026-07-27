# language: pt

@authenticated
Funcionalidade: Detalhe de variante do catálogo autenticado

  Cenário: Consultar uma variante pelo produto e tamanho normalizado
    Dado que eu tenha um produto autenticado do catálogo com variante disponível
    E que eu tenha uma variante autenticada selecionada desse produto
    Quando eu consultar o detalhe dessa variante autenticada
    Então devo receber status code 200
    E o detalhe da variante autenticada deve corresponder à variante selecionada
    E devo validar o contrato da variante autenticada detalhada
    E a resposta autenticada da variante não deve expor campos administrativos internos
