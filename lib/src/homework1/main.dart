import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String data = "0";
  double converted = 0;
  String? error;
  bool isText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EUR TO RON"),
        backgroundColor: Colors.lightGreenAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Image.network("https://www.datocms-assets.com/43475/1684417840-leu-euro.png?auto=format&fit=crop&h=530&w=940",
          fit: BoxFit.fitWidth,
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "enter the amount in EUR",
              errorText: error,
            ),
            keyboardType: TextInputType.number,

            onChanged: (value) {
              setState(() {
                data = value;
              });
            },
          ),
          ElevatedButton(onPressed: (){
            setState((){
              int? intValue = int.tryParse(data);
              if(data.isEmpty || intValue == null) {
                error = "please enter a number";
              }else{
                error = null;
                converted = intValue * 4.5;
                isText = true;
              }
            });
          }, child: const Text("Convert")),
          if(isText)
            Text(""
                "$converted RON",
              style: TextStyle(fontSize: 30),
            )
          else
            Container(),
        ],
      ),
    );
  }
}
