
import 'package:flutter/material.dart';
import '../models/form_model.dart';
import '../layout/form_builder.dart';

class FormPreviewPage extends StatefulWidget {
  final SavedForm form;

  const FormPreviewPage({super.key, required this.form});

  @override
  State<FormPreviewPage> createState() => _FormPreviewPageState();
}

class _FormPreviewPageState extends State<FormPreviewPage> {
  final Map<String, dynamic> formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.form.title),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Submit'),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.form.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ...widget.form.elements.map((element) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FormElementWidget(
                  element: FormElement(
                    type: element['type'],
                    id: element['id'],
                    properties:
                        Map<String, dynamic>.from(element['properties']),
                  ),
                  onValueChanged: (value) {
                    setState(() {
                      formData[element['id']] = value;
                    });
                  },
                  onDelete: () {}, // Disabled in preview mode
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    // Here you can handle the form submission
    // For now, we'll just print the form data
    print('Form Data: $formData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form submitted successfully!'),
      ),
    );
  }
}
