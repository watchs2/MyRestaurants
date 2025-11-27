import 'package:MyRestaurants/screens/edit_screen.dart';
import 'package:MyRestaurants/model/restaurante.dart';
import 'package:flutter/material.dart';
import 'package:MyRestaurants/data/database_handler.dart';
import 'package:MyRestaurants/screens/home_screen.dart';
import 'package:MyRestaurants/services/photo_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DetailsPage extends StatefulWidget {
  final Restaurant restaurant;
  static const String routeName = '/details';

  const DetailsPage({super.key, required this.restaurant});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Restaurant _displayRestaurant;

  late int _currentRating;
  bool _isLoading = false;
  final _db = DatabaseHandler();

  final Color _primaryColor = const Color(0xFFFF5500);

  @override
  void initState() {
    _isLoading = true;
    _displayRestaurant = widget.restaurant;
    _currentRating = widget.restaurant.stars ?? 0;
    _updateAccessTime();
    super.initState();
    _isLoading = false;
  }

  void _updateAccessTime() async {
    await _db.updateRestaurantAccessTime(widget.restaurant.id!);
  }

  Future<void> _refreshData() async {
    final updatedData = await _db.getRestaurantById(_displayRestaurant.id!);
    if (updatedData != null) {
      setState(() {
        _displayRestaurant = Restaurant.fromMap(updatedData);
        _currentRating = _displayRestaurant.stars ?? 0;
      });
    }
  }

  void _updateRating(int newRating) async {
    setState(() => _isLoading = true);
    final db = DatabaseHandler();
    await db.updateRestaurantRating(widget.restaurant.id!, newRating);
    setState(() {
      _currentRating = newRating;
      _isLoading = false;
    });
  }

  void _deleteRestaurant() async {
    setState(() => _isLoading = true);
    final db = DatabaseHandler();
    await db.deleteRestaurant(_displayRestaurant.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_displayRestaurant.name} eliminado!'),
          backgroundColor: const Color.fromARGB(255, 124, 177, 64),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        MyHomePage.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(double lat, double lng) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Localização',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.2020157100.myrestaurants',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = _displayRestaurant;
    final hasImage =
        restaurant.imgUrl != null &&
        PhotoService.getImage(restaurant.imgUrl) != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Fundo ligeiramente cinza
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : CustomScrollView(
              slivers: [
                // 1. CABEÇALHO EXPANSÍVEL COM IMAGEM
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  backgroundColor: _primaryColor,
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () async {
                          await Navigator.of(context)
                              .pushNamed(
                                EditPage.routeName,
                                arguments: _displayRestaurant,
                              )
                              .then((_) {
                                _refreshData();
                              });
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      restaurant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 10),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    background: hasImage
                        ? Image.file(
                            PhotoService.getImage(restaurant.imgUrl)!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_primaryColor, Colors.orange.shade300],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 80,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildInfoTile(
                                  Icons.location_on_outlined,
                                  'Morada',
                                  restaurant.address,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                _buildInfoTile(
                                  Icons.phone_outlined,
                                  'Telefone',
                                  restaurant.phone,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                _buildInfoTile(
                                  Icons.gps_fixed,
                                  'Coordenadas',
                                  '${restaurant.latitude.toStringAsFixed(4)}, ${restaurant.longitude.toStringAsFixed(4)}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starValue = index + 1;
                              final isFilled = starValue <= _currentRating;
                              return IconButton(
                                iconSize: 32,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isFilled ? Icons.star : Icons.star_border,
                                  color: isFilled
                                      ? _primaryColor
                                      : Colors.grey.shade300,
                                ),
                                onPressed: () => _updateRating(starValue),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 20),
                        _buildMap(restaurant.latitude, restaurant.longitude),

                        const SizedBox(height: 40),
                        TextButton.icon(
                          onPressed: _deleteRestaurant,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text('Eliminar Restaurante'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.red.shade50,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
