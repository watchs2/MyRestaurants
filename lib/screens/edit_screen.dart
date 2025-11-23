import 'package:MyRestaurants/data/database_handler.dart';
import 'package:MyRestaurants/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:MyRestaurants/model/restaurante.dart';

class EditPage extends StatefulWidget {
  final Restaurant restaurant;
  static const String routeName = '/edit';
  const EditPage({super.key, required this.restaurant});

  @override
  State<EditPage> createState() => _EditPage();
}

class _EditPage extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _adressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _currentLocation = "";
  double? _latitude;
  double? _longitude;

  final _locationService = LocationService();
  final _db = DatabaseHandler();

  @override
  void initState() {
    super.initState();
    final restaurant = widget.restaurant;
    _nameController.text = restaurant.name;
    _adressController.text = restaurant.address;
    _phoneController.text = restaurant.phone;
    _latitude = restaurant.latitude;
    _longitude = restaurant.longitude;
    _currentLocation = "${restaurant.latitude}, ${restaurant.longitude}";
  }

  Future<void> _loadLocation() async {
    final locationData = await _locationService.getCurrentLocation();
    if (locationData != null) {
      _latitude = locationData.latitude;
      _longitude = locationData.longitude;
      setState(() {
        _currentLocation =
            "${locationData.latitude}, ${locationData.longitude}";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Localização atualizada!')),
        );
      }
    }
  }

  void _editRestaurant() async {
    if (_formKey.currentState!.validate()) {
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, defina a localização GPS.')),
        );
        return;
      }

      final result = await _db.updateRestaurant(
        widget.restaurant.id!,
        _nameController.text,
        _adressController.text,
        _phoneController.text,
        _latitude!,
        _longitude!,
        widget.restaurant.imgUrl,
        widget.restaurant.stars,
      );

      if (result > 0 && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Guardado com sucesso!')));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _adressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Restaurante')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (v) => v!.isEmpty ? 'Inválido' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _adressController,
                decoration: const InputDecoration(
                  labelText: 'Morada',
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (v) => v!.isEmpty ? 'Inválido' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telemóvel',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[0-9]+$').hasMatch(value))
                      return 'Apenas números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5500).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF5500).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.my_location, color: Color(0xFFFF5500)),
                        const SizedBox(width: 8),
                        Text(
                          'Localização',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentLocation,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loadLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Atualizar Localização'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5500),
                          side: const BorderSide(color: Color(0xFFFF5500)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _editRestaurant,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
