import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const API_URL = "https://api.hgbrasil.com/finance?format=json&key=5e4d39a3";

void main() {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        primaryColorDark: Colors.white,
        primaryColorLight: Colors.white,
      ),
    )
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(API_URL);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _realController = TextEditingController();
  TextEditingController _dolarController = TextEditingController();
  TextEditingController _euroController = TextEditingController();

  double _dolar;
  double _euro;

  void _onRealChange(String text){
    if(text.isEmpty){
      _clearAll();
    }

    double real = double.parse(text);
    _dolarController.text = (real/_dolar).toStringAsFixed(2);
    _euroController.text = (real/_euro).toStringAsFixed(2);
  }

  void _onDolarChange(String text){
    if(text.isEmpty){
      _clearAll();
    }

    double dolar = double.parse(text);
    _realController.text = (_dolar * dolar).toStringAsFixed(2);
    _euroController.text = (_dolar * dolar / _euro).toStringAsFixed(2);
  }

  void _onEuroChange(String text){
    if(text.isEmpty){
      _clearAll();
    }

    double euro = double.parse(text);
    _realController.text = (_euro * euro).toStringAsFixed(2);
    _dolarController.text = (_euro * euro / _dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    _realController.text = "";
    _dolarController.text = "";
    _euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("\$ Conversor \$"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                ),
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Erro ao carregar os dados :(",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                  ),
                );
              }else{
                _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      _buildTextField("Reais", "R\$", _realController, _onRealChange),
                      Divider(),
                      _buildTextField("Dólares", "US\$", _dolarController, _onDolarChange),
                      Divider(),
                      _buildTextField("Euros", "€", _euroController, _onEuroChange),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, String prefix, TextEditingController controller, Function func){
    return TextField(
      controller: controller,
      onChanged: func,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.amber,
          ),
          border: OutlineInputBorder(),
          prefixText: prefix,
          prefixStyle: TextStyle(color: Colors.amber, fontSize: 25.0)
      ),
      style: TextStyle(
          color: Colors.amber,
          fontSize: 25.0
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }
}
