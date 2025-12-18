import 'package:flutter/material.dart';

class ComponentOne extends StatefulWidget {
  const ComponentOne({super.key});

  @override
  State<ComponentOne> createState() => _ComponentOneState();
}

class _ComponentOneState extends State<ComponentOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Component One",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Text("Component One"),
    );
  }
}
