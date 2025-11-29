import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) {
        return null;
      }

      return image;
    } catch (e) {
      print("Erro: Falha ao tentar obter imagem: ${e.toString()}");
      return null;
    }
  }

  static Future<String?> saveImage(File imageFile) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    String fileName = path.basename(imageFile.path);
    final String finalPath = '${directory.path}/$fileName';
    final File localImage = await imageFile.copy(finalPath);
    return localImage.path;
  }

  static File? getImage(String? path) {
    if (path == null) {
      return null;
    }
    return File(path);
  }
}
