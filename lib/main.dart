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
    const primaryColor = Color.fromARGB(226, 255, 85, 0);

    return MaterialApp(
      title: 'MyRestaurants',
      debugShowCheckedModeBanner: false, //para remover a faixa de debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: primaryColor,
          surface: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Color.fromARGB(255, 231, 229, 229),
          centerTitle: true,
          elevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            elevation: 2,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          prefixIconColor: primaryColor,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
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
