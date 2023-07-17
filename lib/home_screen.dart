import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _startIsolate();
  }

  void _startIsolate() async {
    final receivePort = ReceivePort();

    await Isolate.spawn(heavyFunction, receivePort.sendPort);

    receivePort.listen((message) {
      if (kDebugMode) {
        print(message);
      }
    });
  }

  static void heavyFunction(SendPort port) {
    // Replace this with your own logic if needed.
    // For demonstration purposes, we'll send the counter value every 1 second.
    int counter = 0;
    Timer.periodic(const Duration(seconds: 5), (timer) {
      counter++;
      port.send(counter);
      loginApiCall();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<bool> loginApiCall() async {
  late http.Response response;
  try {
    response = await http.get(
      Uri.parse('https://reqres.in/api/users/2'),
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
      },
    );
  } on Exception catch (e) {
    if (e is SocketException) {
      if (kDebugMode) {
        print('Failed to connect to the host');
      }
    } else if (e is FormatException) {
      if (kDebugMode) {
        print('Failed to connect to the host');
      }
    } else if (response.statusCode == 500) {}
  }
  if (response.statusCode == 200) {
    String jsonResponse = response.body;
    // Parse the JSON response
    Map<String, dynamic> responseData = jsonDecode(jsonResponse);

    // Extract the email
    String email = responseData['data']['email'];

    if (kDebugMode) {
      print(
          "API call Success(Response Code - ${response.statusCode}) -> $email");
    }
  } else {
    var messages = jsonDecode(response.body);
    Map<String, dynamic> value = messages;
    String element = value.values.elementAt(0);
    if (kDebugMode) {
      print(element);
    }
  }
  var result = response.body;

  if (response.statusCode == 200 && result.runtimeType == String) {
    return true;
  } else {
    return false;
  }
}
