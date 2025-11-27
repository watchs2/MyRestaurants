import 'package:MyRestaurants/data/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:MyRestaurants/model/restaurante.dart';
import 'package:MyRestaurants/screens/create_screen.dart';
import 'package:MyRestaurants/screens/details_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:MyRestaurants/services/location_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  static const String routeName = '/';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _db = DatabaseHandler();

  List<Restaurant> _restaurants = [];
  bool _isloading = false;
  LatLng? _currentPosition;

  //Nome,distancia e data
  String _sortOption = 'Nome';

  @override
  void initState() {
    _initLocationAndData();
    super.initState();
  }

  void _initLocationAndData() async {
    _isloading = true;
    await _fetchRestaurants();
    final locData = await LocationService().getCurrentLocation();
    if (locData != null && mounted) {
      setState(() {
        _currentPosition = LatLng(locData.latitude!, locData.longitude!);
        if (_sortOption == 'Distância') {
          _sortList(_restaurants);
        }
      });
    }
  }

  Future<void> _fetchRestaurants() async {
    _isloading = true;
    final List<Map<String, dynamic>> restaurantMaps = await _db
        .getRestaurants();
    List<Restaurant> fetchedRestaurants = restaurantMaps
        .map((map) => Restaurant.fromMap(map))
        .toList();
    _sortList(fetchedRestaurants);

    setState(() {
      _restaurants = fetchedRestaurants;
      _isloading = false;
    });
  }

  void _sortList(List<Restaurant> list) {
    switch (_sortOption) {
      case 'Nome':
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;

      case 'Recentes':
        list.sort((a, b) => (b.updatedAt ?? 0).compareTo(a.updatedAt ?? 0));
        break;

      case 'Distância':
        if (_currentPosition != null) {
          final Distance distance = const Distance();
          list.sort((a, b) {
            final distA = distance.as(
              LengthUnit.Meter,
              _currentPosition!,
              LatLng(a.latitude, a.longitude),
            );
            final distB = distance.as(
              LengthUnit.Meter,
              _currentPosition!,
              LatLng(b.latitude, b.longitude),
            );
            return distA.compareTo(distB);
          });
        }
        break;
    }
  }

  void _changeSort(String newOption) {
    _initLocationAndData();
    setState(() {
      _sortOption = newOption;
      _sortList(_restaurants);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Restaurantes'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: _changeSort,
            itemBuilder: (BuildContext context) {
              return {'Nome', 'Distância', 'Recentes'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      Icon(
                        choice == _sortOption
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(choice),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
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
                return RestaurantCard(
                  restaurant: restaurant,
                  onReturn: _initLocationAndData,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed(CreatePage.routeName).then((_) {
            _initLocationAndData();
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
  final VoidCallback onReturn;
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onReturn,
  });

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
          ).pushNamed(DetailsPage.routeName, arguments: restaurant).then((_) {
            onReturn();
          });
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
