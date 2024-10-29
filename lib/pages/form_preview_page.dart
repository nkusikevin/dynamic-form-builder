import 'package:flutter/cupertino.dart';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.form.title,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              widget.form.description,

              style: TextStyle(color: Colors.grey[600] , fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade400,
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
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
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        child:  Icon(Icons.send),
        backgroundColor: Colors.blue.shade400,
      ),
    );
  }

  void _submitForm() {
    print('Form Data: $formData');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form submitted successfully!'),
      ),
    );
  }
}


