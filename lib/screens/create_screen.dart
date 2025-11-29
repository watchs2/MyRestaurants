import 'package:MyRestaurants/data/database_handler.dart';
import 'package:MyRestaurants/services/location_service.dart';
import 'package:MyRestaurants/services/photo_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  //localização
  final _locationService = LocationService();
  String _currentLocation = "Localização não definida";
  double? _latitude;
  double? _longitude;

  //bds
  final _db = DatabaseHandler();

  //fotos
  final _photoService = PhotoService();
  File? _selectedImage;

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
          const SnackBar(
            content: Text('Localização obtida com sucesso!'),
            backgroundColor: const Color.fromARGB(255, 124, 177, 64),
          ),
        );
      }
    }
  }

  void _takePhoto() async {
    final file = await _photoService.pickImage(ImageSource.camera);
    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  void _getPhotoGallery() async {
    final file = await _photoService.pickImage(ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  void _createRestaurant() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final adress = _adressController.text;
      final phone = _phoneController.text;

      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor, adicione uma localização.'),
            backgroundColor: const Color.fromARGB(255, 230, 90, 80),
          ),
        );
        return;
      }
      await _db.createRestaurant(
        name,
        adress,
        phone,
        _latitude,
        _longitude,
        _selectedImage,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Restaurante criado com sucesso!'),
          backgroundColor: const Color.fromARGB(255, 124, 177, 64),
        ),
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
                  if (value == null || value.isEmpty) {
                    return 'Insira o telemóvel';
                  }
                  if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                    return 'Insira um número de telemóvel válido';
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
                        label: const Text('Obter a Minha Localização'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5500),
                          side: const BorderSide(color: Color(0xFFFF5500)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
                        const Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFFFF5500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Foto (Opcional)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _selectedImage != null
                        ? Image.file(_selectedImage!, height: 200)
                        : Text("Nenhuma foto selecionada"),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Câmara'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF5500),
                                side: const BorderSide(
                                  color: Color(0xFFFF5500),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _getPhotoGallery,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galeria'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF5500),
                                side: const BorderSide(
                                  color: Color(0xFFFF5500),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
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
