# language: pt

Funcionalidade: Ordenação pública do catálogo

  Cenário: Ordenar catálogo público por nome crescente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens ordenando por nome crescente
    Então devo receber status code 200
    E devo validar que os itens foram ordenados por nome crescente
    E a resposta não deve expor campos proibidos

  Cenário: Ordenar catálogo público por nome decrescente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens ordenando por nome decrescente
    Então devo receber status code 200
    E devo validar que os itens foram ordenados por nome decrescente
    E a resposta não deve expor campos proibidos

  Cenário: Ordenar catálogo público por data de publicação decrescente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens ordenando por publicação decrescente
    Então devo receber status code 200
    E devo validar que os itens foram ordenados por data de publicação decrescente
    E a resposta não deve expor campos proibidos

  Cenário: Ordenar catálogo público com sort inválido
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens com sort inválido
    Então devo receber status code 400
    E devo validar a mensagem de erro para sort inválido
    E a resposta não deve expor campos proibidos

  Cenário: Ordenar catálogo público com direction inválida
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a lista pública de itens com direction inválida
    Então devo receber status code 400
    E devo validar a mensagem de erro para direction inválida
    E a resposta não deve expor campos proibidos
