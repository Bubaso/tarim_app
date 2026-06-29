import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucketName = 'article-images';

  /// Picks an image from the gallery and uploads it to Supabase Storage.
  /// Returns the public URL of the uploaded image, or null if failed/cancelled.
  Future<String?> pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image == null) return null;

      final String extension = image.name.split('.').last;
      final String fileName = '${const Uuid().v4()}.$extension';
      final String filePath = 'editor_uploads/$fileName';

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await _client.storage.from(_bucketName).uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$extension'),
            );
      } else {
        final file = File(image.path);
        await _client.storage.from(_bucketName).upload(
              filePath,
              file,
              fileOptions: FileOptions(contentType: 'image/$extension'),
            );
      }

      final String publicUrl = _client.storage.from(_bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
