import 'package:MyRestaurants/screens/edit_screen.dart';
import 'package:MyRestaurants/model/restaurante.dart';
import 'package:flutter/material.dart';
import 'package:MyRestaurants/data/database_handler.dart';
import 'package:MyRestaurants/screens/home_screen.dart';

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
    _isLoading = true;
    setState(() {
      _currentRating = newRating;
    });

    final db = DatabaseHandler();
    await db.updateRestaurantRating(widget.restaurant.id!, newRating);

    _isLoading = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Avaliação atualizada para $_currentRating estrelas!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _deleteRestaurant() async {
    _isLoading = true;
    setState(() {});
    final db = DatabaseHandler();
    await db.deleteRestaurant(widget.restaurant.id!);

    _isLoading = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restaurante ${widget.restaurant.name} eliminado!'),
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      MyHomePage.routeName,
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;

        final isFilled = starValue <= _currentRating;

        return IconButton(
          icon: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? Colors.amber : Colors.grey,
            size: 40,
          ),
          onPressed: () {
            _updateRating(starValue);
          },
        );
      }),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
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
        title: const Text('Sobre o Restaurante'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        restaurant.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                    const Divider(),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'Morada',
                      value: restaurant.address,
                    ),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Telefone',
                      value: restaurant.phone,
                    ),
                    _buildInfoRow(
                      icon: Icons.gps_fixed,
                      label: 'Coordenadas GPS',
                      value: '${restaurant.latitude}, ${restaurant.longitude}',
                    ),

                    const Divider(height: 40),
                    const Text(
                      'A sua Avaliação:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStarRating(),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              EditPage.routeName,
                              arguments: restaurant,
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _deleteRestaurant();
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
