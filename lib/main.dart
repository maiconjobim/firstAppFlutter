import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  _HomePageState() {
    load();
  }
  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  Future load() async {
    var response = await SharedPreferences.getInstance();
    var data = response.getString('data');
    if (data != null) {
      Iterable decode = jsonDecode(data);
      List<Item> result = decode.map((e) => Item.fromJson(e)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  void handle(item, value) {
    setState(() {
      item.done = value;
      save();
    });
  }

  void removeItem(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  void updateText() {
    if (newTaskController.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskController.text, done: false));
      newTaskController.clear();
      save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(labelText: "Write your task here"),
        ),
        actions: [
          Container(
            child: ButtonBar(),
            color: Colors.brown,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (ctxt, index) {
          final item = widget.items[index];
          return Dismissible(
            key: Key('$index'),
            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) => removeItem(index),
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) => handle(item, value),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: updateText,
      ),
    );
  }
}
