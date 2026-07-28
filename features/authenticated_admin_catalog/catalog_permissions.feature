# language: pt

@authenticated
Funcionalidade: Permissões administrativas do catálogo

  Cenário: Consultar permissões administrativas da conta autenticada
    Quando eu consultar minhas permissões administrativas do catálogo
    Então devo receber status code 200
    E devo validar o contrato das permissões administrativas do catálogo
    E devo validar as roles administrativas retornadas
    E devo validar a origem das permissões administrativas
    E a resposta de permissões não deve expor dados internos de autenticação
