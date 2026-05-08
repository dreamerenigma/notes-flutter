import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const cloudName = 'dry7smggg';
  static const uploadPreset = 'easyshoppin_unsigned';

  Future<String> uploadImage(Uint8List bytes, {String? folder}) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder ?? 'products'
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'image_${DateTime.now().millisecondsSinceEpoch}.png'));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw 'Cloudinary upload failed: $body';
    }

    return jsonDecode(body)['secure_url'];
  }
}
