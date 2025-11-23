import 'package:MyRestaurants/screens/edit_screen.dart';
import 'package:MyRestaurants/model/restaurante.dart';
import 'package:flutter/material.dart';
import 'package:MyRestaurants/data/database_handler.dart';
import 'package:MyRestaurants/screens/home_screen.dart';
import 'package:MyRestaurants/services/photo_service.dart';

class DetailsPage extends StatefulWidget {
  final Restaurant restaurant;
  static const String routeName = '/details';

  const DetailsPage({super.key, required this.restaurant});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late int _currentRating;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.restaurant.stars ?? 0;
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
    await db.deleteRestaurant(widget.restaurant.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.restaurant.name} eliminado!')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        MyHomePage.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5500).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF5500), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamed(EditPage.routeName, arguments: restaurant);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    restaurant.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoTile(
                    Icons.location_on,
                    'MORADA',
                    restaurant.address,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(Icons.phone, 'TELEFONE', restaurant.phone),
                  const Divider(height: 1),
                  _buildInfoTile(
                    Icons.gps_fixed,
                    'GPS',
                    '${restaurant.latitude}, ${restaurant.longitude}',
                  ),
                  if (restaurant.imgUrl != null &&
                      PhotoService.getImage(restaurant.imgUrl) != null)
                    Image.file(
                      PhotoService.getImage(restaurant.imgUrl)!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 40),

                  const Text(
                    'Avaliação',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isFilled = starValue <= _currentRating;
                      return IconButton(
                        iconSize: 40,
                        icon: Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: isFilled
                              ? const Color(0xFFFF5500)
                              : Colors.grey.shade300,
                        ),
                        onPressed: () => _updateRating(starValue),
                      );
                    }),
                  ),

                  const SizedBox(height: 50),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _deleteRestaurant,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar Restaurante'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
