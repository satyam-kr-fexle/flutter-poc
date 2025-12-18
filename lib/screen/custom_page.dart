import 'package:flutter/material.dart';

// Private StatefulWidget
class CustomStateFulWidgets extends StatefulWidget {
  const CustomStateFulWidgets({super.key});

  @override
  CustomStateFulWidgetsState createState() => CustomStateFulWidgetsState();
}

// Private State class
class CustomStateFulWidgetsState extends State<CustomStateFulWidgets> {
  var counter = 0;

  void increseCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Custom Widget",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: InkWell(
        onTap: () {
          increseCounter();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(child: Text("hello $counter")),
        ),
      ),
    );
  }
}
