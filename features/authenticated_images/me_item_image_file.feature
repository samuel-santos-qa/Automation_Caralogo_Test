# language: pt

@authenticated
Funcionalidade: Arquivo de imagem autenticada

  Cenário: Consultar arquivo de uma imagem pronta do proprietário
    Dado que eu tenha o item autenticado controlado com imagem
    E que eu tenha uma imagem autenticada pronta desse item
    Quando eu consultar o arquivo dessa imagem autenticada
    Então devo receber status code 200
    E devo validar que a resposta é uma imagem WebP autenticada
    E devo validar que o arquivo da imagem autenticada não está vazio
    E devo validar o cache privado da imagem autenticada
