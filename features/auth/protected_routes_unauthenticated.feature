# language: pt

Funcionalidade: Proteção de rotas autenticadas sem token

  Esquema do Cenário: Tentar acessar rota protegida sem autenticação
    Quando eu fizer uma requisição GET para "<endpoint>"
    Então devo receber status code de acesso não autorizado
    E a resposta não deve expor campos proibidos

    Exemplos:
      | endpoint        |
      | /me/profile     |
      | /me/brands      |
      | /me/categories  |
      | /me/collections |
      | /me/tags        |
      | /me/items       |
