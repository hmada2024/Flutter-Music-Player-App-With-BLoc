import 'dart:io';
import 'dart:math';

import 'package:just_audio/just_audio.dart';
import 'package:music/model/audio_file_model.dart';
import 'package:on_audio_query/on_audio_query.dart';
// تغيير اسم مكتبة لتجنب التعارض مع المتغيرات
import 'package:path/path.dart' as p;

import '../../utils/utils.dart';

class AudioFileQueries {
  static List<AudioFile> favourite = [];

  // تعديل اسم المتغير من _path إلى path
  static Future<List<AudioFile>> getFiles(String path) async {
    List<AudioFile> audioList = [];
    final isPermissionGranted = await Utils.requestPermission();

    if (isPermissionGranted) {
      // إنشاء الكائن Directory باستخدام المسار المُمرر
      Directory directory = Directory(path);

      // الحصول على قائمة الملفات في المجلد المحدد
      List<FileSystemEntity> files = directory.listSync();

      // قائمة بامتدادات الملفات الصوتية التي سيتم البحث عنها
      List<String> audioExtensions = ['.mp3', '.wav', '.au', '.aac', '.smi', '.flac', '.ogg', '.m4a', '.wma'];

      for (int i = 0; i < files.length; i++) {
        // استخدام مكتبة p للحصول على الامتداد بدون تعارض
        String extension = p.extension(files[i].path).toLowerCase();

        // التحقق إذا كان الامتداد من ضمن الامتدادات الصوتية
        if (audioExtensions.contains(extension)) {
          // الحصول على اسم الملف وحجمه
          String name = p.basename(files[i].path);
          String size = File(files[i].path).lengthSync().toString();
          String length = await getFileLength(files[i].path);
          int isFavourite = 0;

          // إضافة الملف إلى قائمة الملفات الصوتية
          audioList.add(AudioFile(
            id: Random().nextInt(1000000),
            name: name,
            path: files[i].path,
            size: size,
            length: length,
            isFavourite: isFavourite,
          ));
        }
      }
    } else {
      // في حالة عدم منح الأذونات، يتم إرجاع قائمة فارغة
      return [];
    }

    // إرجاع القائمة النهائية من الملفات الصوتية
    return audioList;
  }

  // دالة للحصول على طول الملف الصوتي
  static Future<String> getFileLength(String filePath) async {
    AudioPlayer player = AudioPlayer();
    final _ = await player.setFilePath(filePath);

    // الحصول على الوقت بالدقائق والثواني
    String prefix = player.duration!.inMinutes.toString();
    String postFix = (player.duration!.inSeconds % 60).toString();

    // التأكد من تنسيق الوقت بإضافة 0 إذا كان الرقم أقل من 10
    if (prefix.length < 2) {
      prefix = '0$prefix';
    }
    if (postFix.length < 2) {
      postFix = '0$postFix';
    }
    player.dispose();

    return '$prefix:$postFix';
  }

  // دالة للحصول على جميع المجلدات التي تحتوي على ملفات صوتية
  static Future<List<Map<String, String>>> getFolders() async {
    List<Map<String, String>> list = [];
    final audioQuery = OnAudioQuery();

    // استعلام للحصول على جميع المسارات (المجلدات) المتاحة
    List<String> folders = await audioQuery.queryAllPath();

    // إضافة المجلدات إلى القائمة
    for (var folder in folders) {
      list.add({
        'path': folder,
        'name': p.basename(folder)
      });
    }
    return list;
  }
}
