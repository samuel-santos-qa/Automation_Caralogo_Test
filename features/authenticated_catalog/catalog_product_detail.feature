# language: pt

@authenticated
Funcionalidade: Detalhe de produto do catálogo autenticado

  Cenário: Consultar o detalhe de um produto com variantes
    Dado que eu tenha um produto autenticado do catálogo com variante disponível
    Quando eu consultar o detalhe desse produto autenticado por id
    Então devo receber status code 200
    E o detalhe autenticado deve corresponder ao produto selecionado
    E devo validar o contrato do produto autenticado detalhado
    E a lista de variantes do produto autenticado não deve estar vazia
    E devo validar o contrato das variantes autenticadas retornadas
    E a resposta autenticada de detalhe não deve expor campos administrativos internos
