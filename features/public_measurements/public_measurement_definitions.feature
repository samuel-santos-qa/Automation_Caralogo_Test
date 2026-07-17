# language: pt

@public
Funcionalidade: Measurement definitions públicas

  Cenário: Consultar measurement definitions de perfil público existente
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para as measurement definitions públicas do perfil
    Então devo receber status code 200
    E devo validar o contrato das measurement definitions públicas
    E devo validar que existe uma definition esperada
    E a resposta não deve expor campos proibidos

  Cenário: Consultar measurement definitions de handle inexistente
    Quando eu fizer uma requisição GET para measurement definitions de um handle público inexistente
    Então devo receber status code de recurso indisponível
    E a resposta não deve expor campos proibidos

  Cenário: Consultar measurement definitions com Authorization inválido
    Dado que eu tenha um handle público válido
    Quando eu fizer uma requisição GET para measurement definitions públicas com Authorization inválido
    Então devo receber status code 401
    E a resposta não deve expor campos proibidos
