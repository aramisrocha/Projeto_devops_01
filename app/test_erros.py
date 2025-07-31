def test_soma_parametro_faltando(cliente):
    resposta = cliente.get("/soma?a=5")  # faltando parâmetro b
    assert resposta.status_code == 400
    assert "erro" in resposta.get_json()

def test_inverter_sem_json(cliente):
    resposta = cliente.post("/inverter")  # sem corpo
    assert resposta.status_code in [400, 415]