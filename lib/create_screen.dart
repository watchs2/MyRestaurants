import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

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

  String _currentLocation = "";

  final _locationService = LocationService();
  final _db = DatabaseHandler();

  double? _latitude;
  double? _longitude;

  Future<void> _loadLocation() async {
    //TODO fazer W e N e colocar a bolinha
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

  void _createRestaurant() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final adress = _adressController.text;
      final phone = _phoneController.text;
      //TODO não pode ser null  _latitude, _longitude

      _db.createRestaurant(name, adress, phone, _latitude, _longitude, null);
      //chamar aqui o database handler
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização atualizada com sucesso!')),
      );

      _nameController.clear();
      _adressController.clear();
      _phoneController.clear();

      setState(() {
        _currentLocation = "";
      });
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
        title: const Text('Adicionar Novo Restaurante'),
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
                  hintText: 'Pizzaria do Norte',
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
                  hintText: 'Rua da Liberdade, 42 Lisboa',
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
                  hintText: '913961923',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor insira o telemóvel.';
                  }
                  if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return null;
                  }
                  return 'Por favor insira um numero válido';
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
                    // Botão para usar a localização.
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
                onPressed: _createRestaurant,
                icon: const Icon(Icons.my_location),
                label: const Text('Criar Restaurante'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green.shade700,
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
