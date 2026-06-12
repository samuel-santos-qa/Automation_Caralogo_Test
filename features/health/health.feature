# language: pt

Funcionalidade: Health da API Carálogo

  Cenário: Verificar se a API está saudável
    Quando eu fizer uma requisição GET para "/health"
    Então devo receber status code 200
    E a resposta deve conter o campo "status" com o valor "ok"
