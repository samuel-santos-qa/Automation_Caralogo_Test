# language: pt

@authenticated
Funcionalidade: Tokens de compartilhamento autenticados

  Cenário: Listar metadados dos tokens de compartilhamento de um item
    Dado que eu tenha um item autenticado controlado com histórico de compartilhamento
    Quando eu consultar os tokens de compartilhamento desse item autenticado
    Então devo receber status code 200
    E devo validar o contrato da lista autenticada de tokens de compartilhamento
    E a lista autenticada de tokens de compartilhamento não deve estar vazia
    E devo validar os metadados dos tokens de compartilhamento retornados
    E a resposta autenticada não deve expor tokens ou segredos de compartilhamento
