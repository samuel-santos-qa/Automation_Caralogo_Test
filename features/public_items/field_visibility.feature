# language: pt

Funcionalidade: Field visibility em rotas públicas

  Cenário: Validar que campos públicos aparecem na lista pública de itens
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens
    Então devo receber status code 200
    E devo validar que o item com campos públicos visíveis aparece no catálogo
    E devo validar que description e rating aparecem no item público visível
    E a resposta não deve expor campos proibidos

  Cenário: Validar que campos ocultos não aparecem na lista pública de itens
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens
    Então devo receber status code 200
    E devo validar que o item com campos ocultos aparece no catálogo
    E devo validar que description e rating não aparecem no item com campos ocultos
    E a resposta não deve expor campos proibidos

  Cenário: Validar detalhe público de item com campos visíveis
    Dado que eu tenha um item público com campos visíveis
    Quando eu fizer uma requisição GET para o detalhe público do item de visibilidade
    Então devo receber status code 200
    E devo validar que o detalhe público contém description e rating
    E a resposta não deve expor campos proibidos

  Cenário: Validar detalhe público de item com campos ocultos
    Dado que eu tenha um item público com campos ocultos
    Quando eu fizer uma requisição GET para o detalhe público do item de visibilidade
    Então devo receber status code 200
    E devo validar que o detalhe público não contém description e rating
    E a resposta não deve expor campos proibidos
