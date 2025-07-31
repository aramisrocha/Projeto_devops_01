def test_fluxo_completo(cliente):
    # 1. Somar dois números
    resposta1 = cliente.get("/soma?a=10&b=15")
    assert resposta1.status_code == 200
    resultado1 = resposta1.get_json()["resultado"]
    assert resultado1 == 25.0

    # 2. Usar o resultado anterior no endpoint inverter
    resposta2 = cliente.post("/inverter", json={"texto": str(resultado1)})
    assert resposta2.status_code == 200
    assert resposta2.get_json()["resultado"] == "0.52"
