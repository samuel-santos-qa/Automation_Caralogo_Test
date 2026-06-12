# language: pt

Funcionalidade: Rotas públicas inválidas

  Esquema do Cenário: Consultar rota pública inexistente de forma segura
    Quando eu fizer uma requisição GET para uma rota pública inválida do tipo "<tipo_rota>"
    Então devo receber status code de recurso indisponível
    E a resposta não deve expor campos proibidos

    Exemplos:
      | tipo_rota    |
      | perfil       |
      | itens        |
      | filtros      |
      | detalhe_item |
