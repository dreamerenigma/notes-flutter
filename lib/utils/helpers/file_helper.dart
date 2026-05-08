import 'package:file_selector/file_selector.dart';

class FileHelper {
  static Future<String?> pickFile() async {
    final typeGroup = XTypeGroup(label: 'files', extensions: ['png', 'jpg', 'jpeg', 'pdf']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    return file?.path;
  }
}
