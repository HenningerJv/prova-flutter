import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Escola")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/estudos.png"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaLogin()),
                );
              },
              child: Text("ACESSAR"),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String _token = '';
  String? _erro;

  Future<void> fazerLogin() async {
    String nome = _nomeController.text;
    String senha = _senhaController.text;

    if (nome.isEmpty || senha.isEmpty) {
      setState(() {
        _erro = "Os campos nome e senha são obrigatórios.";
      });
      return;
    }

    setState(() {
      _token = "TOKEN_SIMULADO_12345";
      _erro = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaAlunos(token: _token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fazerLogin,
              child: Text("ENVIAR"),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _erro!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (_token.isNotEmpty)
              Text("Token recebido: $_token"),
          ],
        ),
      ),
    );
  }
}

class TelaAlunos extends StatefulWidget {
  final String token;
  TelaAlunos({required this.token});

  @override
  _TelaAlunosState createState() => _TelaAlunosState();
}

class _TelaAlunosState extends State<TelaAlunos> {
  List<Map<String, dynamic>> alunos = [];
  String filtro = "todos";
  bool isLoading = true; // Indica se os dados estão carregando
  String? errorMessage;  // Para exibir erro se a requisição falhar

  // Substitua essa função pela versão nova
  Future<void> buscarNotasAlunos() async {
    final String url = 'https://demo8149697.mockable.io/notasAlunos'; // Substitua com a sua URL

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Processa os dados
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          alunos = data.map((item) {
            return {
              "nome": item["nome"],
              "nota": item["nota"]
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar os dados: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro de conexão: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    buscarNotasAlunos(); // Chama a função ao inicializar a tela
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> alunosFiltrados = alunos.where((aluno) {
      switch (filtro) {
        case "<60":
          return aluno["nota"] < 60;
        case ">=60":
          return aluno["nota"] >= 60 && aluno["nota"] < 100;
        case "100":
          return aluno["nota"] == 100;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Notas dos Alunos")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filtro = "<60";
                  });
                },
                child: Text("<60"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filtro = ">=60";
                  });
                },
                child: Text(">=60"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    filtro = "100";
                  });
                },
                child: Text("100"),
              ),
            ],
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // Mostra o indicador de carregamento
                : errorMessage != null
                    ? Center(child: Text(errorMessage!)) // Exibe erro se houver
                    : ListView.builder(
                        itemCount: alunosFiltrados.length,
                        itemBuilder: (context, index) {
                          final aluno = alunosFiltrados[index];
                          Color cor;
                          if (aluno["nota"] == 100) {
                            cor = Colors.green;
                          } else if (aluno["nota"] >= 60) {
                            cor = Colors.blue;
                          } else {
                            cor = Colors.yellow;
                          }
                          return Container(
                            color: cor,
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(aluno["nome"]),
                                Text(aluno["nota"].toString()),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
