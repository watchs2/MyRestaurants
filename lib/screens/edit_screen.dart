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
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Localização atualizada com sucesso!')),
    );
  }

  void _editRestaurant() async {
    if (_formKey.currentState!.validate()) {
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, defina a localização GPS.')),
        );
        return;
      }

      final restaurantId = widget.restaurant.id;
      final updatedName = _nameController.text;
      final updatedAddress = _adressController.text;
      final updatedPhone = _phoneController.text;

      final result = await _db.updateRestaurant(
        restaurantId!,
        updatedName,
        updatedAddress,
        updatedPhone,
        _latitude!,
        _longitude!,
        widget.restaurant.imgUrl,
        widget.restaurant.stars,
      );

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurante atualizado com sucesso!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar o restaurante. Tente novamente.'),
          ),
        );
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
  Widget build(buildContext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Restaurante'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Restaurante',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira um nome válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _adressController,
                decoration: const InputDecoration(
                  labelText: 'Morada do Restaurante',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira uma morada válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telémovel do Restaurante',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  // Permite que o campo fique vazio, mas se tiver valor, valida
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Por favor insira um numero válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.blueGrey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Localização GPS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blueGrey.shade200),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        _currentLocation,
                        style: TextStyle(
                          fontStyle:
                              _currentLocation == 'Localização não definida'
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _loadLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Usar a minha localização'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
