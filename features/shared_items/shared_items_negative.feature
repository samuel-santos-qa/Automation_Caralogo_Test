# language: pt

Funcionalidade: Share token inválido

  Cenário: Consultar item compartilhado com token inválido
    Quando eu fizer uma requisição GET para um share token inválido
    Então devo receber status code de recurso indisponível
    E a resposta não deve expor campos proibidos
