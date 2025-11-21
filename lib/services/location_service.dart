import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<LocationData?> getCurrentLocation() async {
    bool _serviceEnable;
    PermissionStatus _permissionGranted;

    _serviceEnable = await location.serviceEnabled();
    if (!_serviceEnable) {
      _serviceEnable = await location.requestService();
      if (!_serviceEnable) {
        print("Erro:Serviço de localização desativado pelo user");
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        print("Erro:Permissão de localização rejeitada pelo user");
        return null;
      }
    }

    try {
      return await location.getLocation();
    } catch (e) {
      print("Erro: Existiu um erro a pedir localização ${e.toString()}");
      return null;
    }
  }
}
