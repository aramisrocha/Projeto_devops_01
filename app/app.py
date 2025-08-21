from flask import Flask, request, jsonify

app = Flask(__name__)
# Testando o codigo 04
@app.route("/soma", methods=["GET"])
def soma():
    try:
        if "a" not in request.args or "b" not in request.args:
            return jsonify({"erro": "Parâmetro faltando."}), 400

        a = float(request.args.get("a"))
        b = float(request.args.get("b"))
        return jsonify({"resultado": a + b})
    except ValueError:
        return jsonify({"erro": "Parâmetros inválidos."}), 400


@app.route("/inverter", methods=["POST"])
def inverter():
    dados = request.get_json()
    texto = dados.get("texto", "")
    return jsonify({"resultado": texto[::-1]})

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
