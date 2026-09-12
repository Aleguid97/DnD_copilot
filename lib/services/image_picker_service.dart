import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens a file picker for images, copies the selected file into the
/// app's documents directory (so it persists reliably), and returns
/// the new stored path — or null if the user cancelled.
Future<String?> pickAndStoreCharacterImage() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result == null || result.files.single.path == null) return null;

  final pickedPath = result.files.single.path!;
  final docsDir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory(p.join(docsDir.path, 'character_images'));
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  final extension = p.extension(pickedPath);
  final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
  final newPath = p.join(imagesDir.path, fileName);

  await File(pickedPath).copy(newPath);
  return newPath;
}
