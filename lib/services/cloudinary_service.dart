import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({
    String? cloudName,
    String? uploadPreset,
  })  : cloudName =
            cloudName ?? const String.fromEnvironment('CLOUDINARY_CLOUD_NAME'),
        uploadPreset = uploadPreset ??
            const String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');

  Future<String?> uploadImageBytes(
    Uint8List bytes, {
    String filename = 'upload.jpg',
  }) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      return null;
    }

    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String?;
    }
    return null;
  }
}
