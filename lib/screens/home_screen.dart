import 'package:MyRestaurants/data/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:MyRestaurants/model/restaurante.dart';
import 'package:MyRestaurants/screens/create_screen.dart';
import 'package:MyRestaurants/screens/details_screen.dart';

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
      appBar: AppBar(title: const Text('Meus Restaurantes')),
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : _restaurants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum restaurante adicionado ainda.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _restaurants.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 12),
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
        tooltip: 'Adicionar Restaurante',
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
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(DetailsPage.routeName, arguments: restaurant);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant, color: theme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.visibility, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
