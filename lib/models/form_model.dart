// models/form_model.dart
import 'package:hive/hive.dart';

part 'form_model.g.dart';

@HiveType(typeId: 0)
class SavedForm extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  List<Map<String, dynamic>> elements;

  SavedForm({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.elements,
  });

  factory SavedForm.create({
    required String title,
    required String description,
    required List<Map<String, dynamic>> elements,
  }) {
    final now = DateTime.now();
    return SavedForm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      elements: elements,
    );
  }
}

// Run 'flutter pub run build_runner build' after creating this file to generate the adapter