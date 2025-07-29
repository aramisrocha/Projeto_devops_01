import pytest
from app import app

@pytest.fixture
def cliente():
    app.testing = True
    return app.test_client()

def test_soma_ok(cliente):
    resposta = cliente.get("/soma?a=5&b=7")
    assert resposta.status_code == 200
    assert resposta.get_json()["resultado"] == 12.0

def test_soma_invalida(cliente):
    resposta = cliente.get("/soma?a=abc&b=3")
    assert resposta.status_code == 400

def test_inverter_texto(cliente):
    resposta = cliente.post("/inverter", json={"texto": "OpenAI"})
    assert resposta.status_code == 200
    assert resposta.get_json()["resultado"] == "IAnepO"

# Testes de Integração


#  Testes de Contrato


# Testes de Validação de Erros