import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _value = 50;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Cupertino native slider demo:'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CNSlider(
                  value: _value,
                  min: 0,
                  max: 100,
                  enabled: true,
                  onChanged: (v) => setState(() => _value = v),
                ),
              ),
              Text('Value: ${_value.toStringAsFixed(1)}'),
            ],
          ),
        ),
      ),
    );
  }
}
