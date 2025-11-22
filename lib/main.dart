import 'package:MyRestaurants/create_screen.dart';
import 'package:MyRestaurants/details_screen.dart';
import 'package:MyRestaurants/model/restaurante.dart';
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
        DetailsPage.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Restaurant;
          return DetailsPage(restaurant: args);
        },
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

  List<Restaurant> _restaurants = [];
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    final List<Map<String, dynamic>> restaurantMaps = await _db
        .getRestaurants();
    final List<Restaurant> fetchedRestaurants = restaurantMaps
        .map((map) => Restaurant.fromMap(map))
        .toList();
    setState(() {
      _restaurants = fetchedRestaurants;
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Restaurantes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : _restaurants.isEmpty
          ? const Center(child: Text('Nenhum restaurante adicionado ainda.'))
          : ListView.builder(
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
                return RestaurantCard(restaurant: restaurant);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(CreatePage.routeName).then((_) {
            _fetchRestaurants();
          });
        },
        tooltip: 'Create Restaurant',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Text(
          restaurant.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.deepPurple,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    restaurant.address,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  restaurant.phone ?? 'N/A',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(DetailsPage.routeName, arguments: restaurant);
          //tlvz tenha de colocar um then
        },
      ),
    );
  }
}
