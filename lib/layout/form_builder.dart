// form_builder.dart
import 'package:flutter/material.dart';

class FormElement {
  final String type;
  final String id;
  Map<String, dynamic> properties;
  dynamic value;

  FormElement({
    required this.type,
    required this.id,
    this.properties = const {},
    this.value,
  });

  // Helper method to get label or default to field type
  String get label => properties['label'] ?? type;
}

class FormBuilderState extends ChangeNotifier {
  List<FormElement> elements = [];

  void addElement(String type) {
    final element = FormElement(
      type: type,
      id: DateTime.now().toString(),
      properties: _getDefaultProperties(type),
    );
    elements.add(element);
    notifyListeners();
  }

  Map<String, dynamic> _getDefaultProperties(String type) {
    switch (type) {
      case 'Text Field':
        return {
          'label': 'New Text Field',
          'hint': 'Enter text',
          'required': false,
        };
      case 'Dropdown':
        return {
          'label': 'New Dropdown',
          'options': ['Option 1', 'Option 2', 'Option 3'],
          'required': false,
        };
      case 'Checkbox':
        return {
          'label': 'New Checkbox',
          'required': false,
        };
      case 'Radio Button':
        return {
          'label': 'New Radio Group',
          'options': ['Option 1', 'Option 2', 'Option 3'],
          'required': false,
        };
      case 'Date Picker':
        return {
          'label': 'New Date Picker',
          'required': false,
        };
      default:
        return {'label': 'New Field'};
    }
  }

  void removeElement(String id) {
    elements.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void reorderElements(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final element = elements.removeAt(oldIndex);
    elements.insert(newIndex, element);
    notifyListeners();
  }

  void updateElementValue(String id, dynamic value) {
    final elementIndex = elements.indexWhere((element) => element.id == id);
    if (elementIndex != -1) {
      elements[elementIndex].value = value;
      notifyListeners();
    }
  }
}

class FormElementWidget extends StatefulWidget {
  final FormElement element;
  final VoidCallback onDelete;
  final Function(dynamic) onValueChanged;

  const FormElementWidget({
    Key? key,
    required this.element,
    required this.onDelete,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<FormElementWidget> createState() => _FormElementWidgetState();
}

class _FormElementWidgetState extends State<FormElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getIconForType(widget.element.type),
                const SizedBox(width: 8),
                Text(
                  widget.element.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildFormField(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField() {
    switch (widget.element.type) {
      case 'Text Field':
        return TextField(
          decoration: InputDecoration(
            hintText: widget.element.properties['hint'],
            border: const OutlineInputBorder(),
          ),
          onChanged: widget.onValueChanged,
        );

      case 'Dropdown':
        return DropdownButtonFormField<String>(
          value: widget.element.value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: (widget.element.properties['options'] as List)
              .map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option.toString(),
              child: Text(option.toString()),
            );
          }).toList(),
          onChanged: (value) => widget.onValueChanged(value),
        );

      case 'Checkbox':
        return CheckboxListTile(
          title: Text(widget.element.label),
          value: widget.element.value ?? false,
          onChanged: (value) => widget.onValueChanged(value),
          contentPadding: EdgeInsets.zero,
        );

      case 'Radio Button':
        return Column(
          children: (widget.element.properties['options'] as List)
              .map<Widget>((option) {
            return RadioListTile<String>(
              title: Text(option.toString()),
              value: option.toString(),
              groupValue: widget.element.value,
              onChanged: (value) => widget.onValueChanged(value),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );

      case 'Date Picker':
        return OutlinedButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: widget.element.value ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              widget.onValueChanged(date);
            }
          },
          child: Text(
            widget.element.value != null
                ? widget.element.value.toString().split(' ')[0]
                : 'Select Date',
          ),
        );

      default:
        return const Text('Unsupported field type');
    }
  }

  Icon _getIconForType(String type) {
    switch (type) {
      case 'Text Field':
        return const Icon(Icons.text_fields);
      case 'Dropdown':
        return const Icon(Icons.arrow_drop_down_circle);
      case 'Checkbox':
        return const Icon(Icons.check_box);
      case 'Radio Button':
        return const Icon(Icons.radio_button_checked);
      case 'Date Picker':
        return const Icon(Icons.calendar_today);
      default:
        return const Icon(Icons.widgets);
    }
  }
}
