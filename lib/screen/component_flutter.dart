import 'package:flutter/material.dart';
import 'package:learningday1/screen/component_one.dart';

class FlutterComponent extends StatefulWidget {
  const FlutterComponent({super.key});

  @override
  State<FlutterComponent> createState() => _FlutterComponentState();
}

class _FlutterComponentState extends State<FlutterComponent> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepPurple,
          title: const Text(
            "Tab",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Open Dialog"),
              Tab(text: "Open Bottom Sheet"),
              Tab(text: "Show Image"),
            ],
          ),
        ),

        // 🔴 IMPORTANT PART
        body: Column(
          children: [
            // TAB CONTENT
            Expanded(
              child: TabBarView(
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Are you Sure?"),
                            content: const Text("This Is Some Description"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text("Ok"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("Open Dialog"),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Container(
                            height: 120,
                            color: Colors.green,
                            child: const Center(child: Text("First Data")),
                          ),
                        );
                      },
                      child: const Text("Open Bottom Sheet"),
                    ),
                  ),
                  Center(
                    child: Image.asset("assets/images/images.jpg", height: 120),
                  ),
                ],
              ),
            ),

            // 👇 THIS TEXT IS BELOW TABS (STATIC)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: const Text(
                "This text is always visible below the tabs",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(16),
            //   child: ComponentOne(),
            // ),
          ],
        ),
      ),
    );
  }
}
