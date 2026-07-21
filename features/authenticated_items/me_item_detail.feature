# language: pt

@authenticated
Funcionalidade: Detalhe de item autenticado

  Cenário: Consultar detalhe de um item do proprietário
    Dado que eu tenha um item autenticado disponível
    Quando eu consultar o detalhe desse item autenticado
    Então devo receber status code 200
    E devo validar o contrato do detalhe do item autenticado
    E o detalhe retornado deve pertencer ao item autenticado selecionado
    E a resposta autenticada de itens não deve expor campos internos proibidos
