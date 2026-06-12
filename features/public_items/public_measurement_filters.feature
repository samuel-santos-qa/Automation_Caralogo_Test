# language: pt

Funcionalidade: Filtros públicos por measurements

  Cenário: Filtrar catálogo público por measurement em centímetros
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por measurement em centímetros
    Então devo receber status code 200
    E devo validar que o catálogo público possui o item esperado
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por measurement em milímetros
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por measurement em milímetros
    Então devo receber status code 200
    E devo validar que o catálogo público possui o item esperado
    E a resposta não deve expor campos proibidos

  Cenário: Filtrar catálogo público por measurement fora do intervalo
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens filtrando por measurement fora do intervalo
    Então devo receber status code 200
    E devo validar que o catálogo público retornou vazio
    E a resposta não deve expor campos proibidos
