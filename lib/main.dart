import 'package:flutter/material.dart'; // using default design
import 'package:http/http.dart' as http; // using HTTP communication
import 'dart:async'; // using asynchronous
import 'dart:convert'; // using JSON

// Api url (Application Programming Interface)
const url = "https://api.hgbrasil.com/finance?format=json&key=ec191454";

// Start application
void main() async {
  runApp(MyApp());
}

Widget MyApp() {
  return MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white
    ),
  );
}

// Request data from api
Future<Map> getData() async {

  // Request http (method GET)
  http.Response response = await http.get(url);

  // Return data format as Map (JSON)
  return json.decode(response.body);
}

// Widget main (Stateful)
class Home extends StatefulWidget {
  @override
  _HomeState createState() {
    return _HomeState();
  }
}

// My widget
class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar;
  double euro;

  void _realChanged(String txt) {

    // Check if is empty
    if(txt.isEmpty) {
      _clearAll();
      return;
    }

    // Convert string to double
    double real = double.parse(txt);

    // Convert real to dollar/euro
    dollarController.text = (real/dollar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dollarChanged(String txt) {
    if(txt.isEmpty) {
      _clearAll();
      return;
    }

    // Convert string to double
    double dollar = double.parse(txt);

    // Convert dollar to real/euro
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String txt) {

    // Check if is empty
    if(txt.isEmpty) {
      _clearAll();
      return;
    }

    // Convert string to double
    double euro = double.parse(txt);

    // Convert euro to real/dollar
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
  }

  // Clean input data
  void _clearAll() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {

    // Screen
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text("My Currency"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Corregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center
                  ),
                );
              default:
                if(snapshot.hasError) {
                  // Failed in get data
                  return Center(
                    child: Text(
                      "Erro ao Carregar Dados :(",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }else {

                  // Get specific data
                  dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro   = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "US\$", dollarController, _dollarChanged),
                        Divider(),
                        buildTextField("Euros", "€", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

// Widget fragment
Widget buildTextField(String label, String prefix, TextEditingController txtController, Function txtChanged) {
  return TextField(
    controller: txtController,
    onChanged: txtChanged,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0
    ),
  );
}
