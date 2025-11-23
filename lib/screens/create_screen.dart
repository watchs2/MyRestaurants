import 'package:MyRestaurants/data/database_handler.dart';
import 'package:MyRestaurants/services/location_service.dart';
import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});
  static const String routeName = '/create';

  @override
  State<CreatePage> createState() => _CreatePage();
}

class _CreatePage extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _adressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _currentLocation = "Localização não definida";
  double? _latitude;
  double? _longitude;

  final _locationService = LocationService();
  final _db = DatabaseHandler();

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
          const SnackBar(content: Text('Localização obtida com sucesso!')),
        );
      }
    }
  }

  void _createRestaurant() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final adress = _adressController.text;
      final phone = _phoneController.text;

      _db.createRestaurant(name, adress, phone, _latitude, _longitude, null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurante criado com sucesso!')),
      );

      _nameController.clear();
      _adressController.clear();
      _phoneController.clear();

      setState(() {
        _currentLocation = "Localização não definida";
        _latitude = null;
        _longitude = null;
      });

      Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Novo Restaurante')),
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
                  labelText: 'Nome do Restaurante',
                  hintText: 'Ex: Pizzaria do Norte',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Insira um nome' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _adressController,
                decoration: const InputDecoration(
                  labelText: 'Morada',
                  hintText: 'Ex: Rua da Liberdade, 42',
                  prefixIcon: Icon(Icons.map),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Insira uma morada' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telemóvel',
                  hintText: 'Ex: 912345678',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Insira o telemóvel';
                  if (!RegExp(r'^[0-9]+$').hasMatch(value))
                    return 'Apenas números';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Card de Localização simplificado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFF5500,
                  ).withOpacity(0.05), // Laranja muito suave
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
                          'Coordenadas GPS',
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
                        icon: const Icon(Icons.gps_fixed),
                        label: const Text('Obter Minha Localização'),
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
                onPressed: _createRestaurant,
                icon: const Icon(Icons.check),
                label: const Text('Criar Restaurante'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
