import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uni_clima/model/clima_model.dart';
import 'package:uni_clima/widgets/clima_widget.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ClimaModel climaModel;
  bool _isLoading = false;

  final List<String> _cidades = [
    "Aracaju",
    "Belém",
    "Belo Horizonte",
    "Boa Vista",
    "Brasilia",
    "Campo Grande",
    "Cuiaba",
    "Curitiba",
    "Florianópolis",
    "Fortaleza",
    "Goiânia",
    "João Pessoa",
    "Macapá",
    "Maceió",
    "Manaus",
    "Natal",
    "Palmas",
    "Porto Alegre",
    "Porto Velho",
    "Recife",
    "Rio Branco",
    "Rio de Janeiro",
    "Salvador",
    "São Luis",
    "São Paulo",
    "Teresina",
    "Vitória"
  ];

  String _cidadeSelecionada = "São Paulo";

  @override
  void initState() {
    super.initState();
    carregaClima();
  }

  carregaClima() async {
    setState(() {
      _isLoading = true;
    });

    const String _apiURL =
        "api.openweathermap.org"; //link da API do OpenWeatherMap
    const String _path = "/data/2.5/weather"; //a pasta da API
    const String _appid = ""; //SUA chave de API
    const String _units = "metric";
    const String _lang = "pt_br";

    final _parametros = {
      "q": _cidadeSelecionada,
      "appid": _appid,
      "units": _units,
      "lang": _lang
    };

    final tempoResponse =
        await http.get(Uri.https(_apiURL, _path, _parametros));

    //apenas para fins de depuração:
    //print("URL Montada:" + tempoResponse.request!.url.toString());

    if (tempoResponse.statusCode == 200) {
      setState(() {
        _isLoading = false;
        climaModel = ClimaModel.fromJson(jsonDecode(tempoResponse.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;

    return Scaffold(
      appBar: AppBar(
        title: Text(_cidadeSelecionada),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            DropdownSearch<String>(
              mode: Mode.MENU,
              showSelectedItems: true,
              dropdownSearchDecoration:
                  InputDecoration(hintText: _cidadeSelecionada),
              items: _cidades,
              showSearchBox: true,
              maxHeight: height - padding.top - padding.bottom - 70,
              onChanged: (value) {
                setState(() {
                  _cidadeSelecionada = value!;
                  carregaClima();
                });
              },
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(6),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        )
                      : climaModel != null
                          ? ClimaWidget(climaData: climaModel)
                          : Text(
                              "Sem dados para exibir!",
                              style: Theme.of(context).textTheme.headline4,
                            ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: _isLoading
                        ? Text(
                            "Carregando...",
                            style: Theme.of(context).textTheme.headline5,
                          )
                        : IconButton(
                            onPressed: carregaClima,
                            icon: const Icon(Icons.refresh),
                            iconSize: 50,
                            color: Colors.blue,
                            tooltip: "Recarregar clima",
                          ))
              ],
            ))
          ],
        ),
      ),
    );
  }
}
