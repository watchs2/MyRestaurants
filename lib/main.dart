import 'package:MyRestaurants/create_screen.dart';
import 'package:flutter/material.dart';
import 'package:MyRestaurants/data/database_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyRestaurants',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName: (context) => const MyHomePage(),
        CreatePage.routeName: (context) => const CreatePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  static const String routeName = '/';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _db = DatabaseHandler();
  void loadRestaurants() async {
    List<Map<String, dynamic>> restaurantes = await _db.getRestaurants();
    print(restaurantes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            FloatingActionButton(
              onPressed: loadRestaurants,
              tooltip: 'LoadRestaurants',
              child: const Icon(Icons.list),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(CreatePage.routeName);
        },
        tooltip: 'Create Restaurant',
        child: const Icon(Icons.add),
      ),
    );
  }
}
