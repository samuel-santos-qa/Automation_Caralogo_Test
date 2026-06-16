# language: pt

Funcionalidade: Paginação com ordenação pública do catálogo

  Cenário: Consultar primeira página do catálogo ordenado por nome crescente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a primeira página do catálogo ordenado por nome crescente
    Então devo receber status code 200
    E devo validar os dados da primeira página ordenada
    E devo validar que os itens da resposta estão em ordem crescente por nome
    E a resposta não deve expor campos proibidos

  Cenário: Consultar segunda página do catálogo ordenado por nome crescente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para a segunda página do catálogo ordenado por nome crescente
    Então devo receber status code 200
    E devo validar os dados da segunda página ordenada
    E a resposta não deve expor campos proibidos

  Cenário: Validar ordenação por nome preservada entre páginas
    Dado que eu tenha um handle público válido
    Quando eu consultar as duas primeiras páginas do catálogo ordenado por nome crescente
    Então devo validar que os itens combinados das páginas estão em ordem crescente por nome
    E a resposta não deve expor campos proibidos nas páginas consultadas
