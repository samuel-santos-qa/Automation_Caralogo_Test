# language: pt

@authenticated
Funcionalidade: Imagens de item autenticado

  Cenário: Listar imagens de um item do proprietário
    Dado que eu tenha um item autenticado disponível
    Quando eu consultar as imagens desse item autenticado
    Então devo receber status code 200
    E devo validar o contrato da lista de imagens autenticadas
    E devo validar o contrato das imagens autenticadas retornadas
    E as imagens autenticadas devem estar na ordem esperada
    E a resposta autenticada de imagens não deve expor campos internos proibidos
