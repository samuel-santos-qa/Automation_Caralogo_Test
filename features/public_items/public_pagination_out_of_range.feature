# language: pt

Funcionalidade: Paginação pública fora do range

  Cenário: Consultar página imediatamente após a última página disponível
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para uma página pública imediatamente após a última página disponível
    Então devo receber status code 200
    E devo validar que a página fora do range retornou catálogo vazio
    E a resposta não deve expor campos proibidos

  Cenário: Consultar página pública muito acima do total de páginas
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para uma página pública muito acima do total de páginas
    Então devo receber status code 200
    E devo validar que a página muito acima do range retornou catálogo vazio
    E a resposta não deve expor campos proibidos
