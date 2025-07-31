def test_soma_contrato(cliente):
    resposta = cliente.get("/soma?a=2&b=3")
    assert resposta.status_code == 200

    dados = resposta.get_json()
    # Garante que a chave 'resultado' exista e seja numérica
    assert "resultado" in dados
    assert isinstance(dados["resultado"], (int, float))
