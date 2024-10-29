// pages/form_index.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/form_model.dart';
import './form_preview_page.dart';
import '../layout/layout.dart';  


class FormIndexPage extends StatefulWidget {
  const FormIndexPage({super.key});

  @override
  State<FormIndexPage> createState() => _FormIndexPageState();
}

class _FormIndexPageState extends State<FormIndexPage> {
  late Box<SavedForm> formsBox;

  @override
  void initState() {
    super.initState();
    formsBox = Hive.box<SavedForm>('forms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Forms' , style: TextStyle(
          color: Colors.white,
        ),),
        backgroundColor: Colors.blue.shade400,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.add),
            onPressed: () => _createNewForm(context),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: formsBox.listenable(),
        builder: (context, Box<SavedForm> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.note_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No forms yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _createNewForm(context),
                    child: const Text('Create New Form'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final form = box.getAt(index)!;
              return _buildFormCard(context, form);
            },
          );
        },
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, SavedForm form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showFormActions(context, form),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      form.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showFormActions(context, form),
                  ),
                ],
              ),
              if (form.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  form.description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ${_formatDate(form.createdAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    '${form.elements.length} fields',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showFormActions(BuildContext context, SavedForm form) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.preview),
                title: const Text('Preview'),
                onTap: () => Navigator.pop(context, 'preview'),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    switch (result) {
      case 'edit':
        _editForm(context, form);
        break;
      case 'preview':
        _previewForm(context, form);
        break;
      case 'delete':
        _deleteForm(context, form);
        break;
    }
  }

  void _createNewForm(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';

        return AlertDialog(
          title: const Text('Create New Form'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Form Title',
                  hintText: 'Enter form title',
                ),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter form description',
                ),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  Navigator.pop(context, {
                    'title': title,
                    'description': description,
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final newForm = SavedForm.create(
        title: result['title']!,
        description: result['description']!,
        elements: [],
      );

      await formsBox.add(newForm);

      if (mounted) {
        print('newForm: $newForm');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Layout(form: newForm),
          ),
        );
      }
    }
  }

  void _editForm(BuildContext context, SavedForm form) {
    print('editForm: $form');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Layout(form: form),
      ),
    );
  }

  void _previewForm(BuildContext context, SavedForm form) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPreviewPage(form: form),
      ),
    );
  }

  Future<void> _deleteForm(BuildContext context, SavedForm form) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Form'),
          content: const Text(
            'Are you sure you want to delete this form? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await form.delete();
    }
  }
}
