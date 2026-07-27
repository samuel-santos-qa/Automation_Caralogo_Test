# language: pt

@authenticated
Funcionalidade: Detalhe de produto por slug no catálogo autenticado

  Cenário: Consultar o detalhe de um produto por slug
    Dado que eu tenha um produto autenticado do catálogo com variante disponível
    Quando eu consultar o detalhe desse produto autenticado por slug
    Então devo receber status code 200
    E o detalhe autenticado por slug deve corresponder ao produto selecionado
    E devo validar o contrato do produto autenticado detalhado
    E a lista de variantes do produto autenticado não deve estar vazia
    E devo validar o contrato das variantes autenticadas retornadas
    E a resposta autenticada de detalhe não deve expor campos administrativos internos
