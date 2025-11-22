import 'package:MyRestaurants/screens/create_screen.dart';
import 'package:MyRestaurants/screens/home_screen.dart';
import 'package:MyRestaurants/screens/details_screen.dart';
import 'package:MyRestaurants/screens/edit_screen.dart';
import 'package:MyRestaurants/model/restaurante.dart';
import 'package:flutter/material.dart';

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
        DetailsPage.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Restaurant;
          return DetailsPage(restaurant: args);
        },
        EditPage.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Restaurant;
          return EditPage(restaurant: args);
        },
      },
    );
  }
}
