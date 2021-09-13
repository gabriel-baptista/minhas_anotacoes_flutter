import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helper/anotacaoHelper.dart';
import 'package:minhas_anotacoes/model/anotacao.dart';
// pacote para fazer a formatação da data
import 'package:intl/intl.dart';
// import para selecionar o local de formatação da data ex: pt-BR
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = [];

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String textoSalvarAtualizar = '';
    if (anotacao == null) {
      _tituloController.text = '';
      _descricaoController.text = '';
      textoSalvarAtualizar = 'Salvar';
    } else {
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizar = 'Atualizar';
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Adicionar anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título", hintText: "Digite título..."),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição", hintText: "Digite descrição..."),
                )
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text(
                  textoSalvarAtualizar,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  //salvar
                  _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);

                  Navigator.pop(context);
                  _tituloController.text = '';
                  _descricaoController.text = '';
                },
              ),
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    List<Anotacao> listaTemporaria = [];
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }
    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = [];

    print("Lista anotacoes: " + anotacoesRecuperadas.toString());
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) {
      // salvar
      Anotacao anotacao = Anotacao(DateTime.now().millisecondsSinceEpoch,
          titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
      print("salvar anotacao: " + resultado.toString());
    } else {
      //atualizar
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      // ignore: unused_local_variable
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }
    //print("data atual: " + DateTime.now().toString() );

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();
  }

  // formatar a data
  _formatarData(String data) {
    // selecionando o local da formatação da data
    initializeDateFormatting('pt_BR');

    // formatando a data em dia/mes/ano
    // var formatador = DateFormat('dd/MM/y');

    // formatando a data com o mes abreviado em 3 letras
    // var formatador = DateFormat('d/MMM/y');

    // formatando a data com o nome do mes completo
    // var formatador = DateFormat('d/MMMM/y');

    // formatando a data em dia/mes/ano com horas:minutos:segundos
    // var formatador = DateFormat('d/M/y H:m:s');

    // outra forma de formatar a data é:
    // formata a data de acordo com o local que colocou como parametro
    var formatador = DateFormat.yMd('pt-BR');

    // formata a data com o mes abreviado de acordo com o local
    // var formatador = DateFormat.yMMMd('pt-BR');

    // formata a data o nome do mes completo de acordo com o local
    // var formatador = DateFormat.yMMMMd('pt-BR');

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);

    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoes.length,
              itemBuilder: (context, index) {
                final anotacao = _anotacoes[index];

                return Card(
                  child: ListTile(
                    title: Text(anotacao.titulo),
                    subtitle: Text(
                        '${anotacao.descricao} - ${_formatarData(anotacao.data)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                          onTap: () {
                            _exibirTelaCadastro(anotacao: anotacao);
                          },
                        ),
                        GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () {
                            _removerAnotacao(anotacao.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: () {
            _exibirTelaCadastro();
          }),
    );
  }
}
