// properties_sidebar.dart
import 'package:flutter/material.dart';
import 'package:dart_form_builder/layout/form_builder.dart';

class PropertiesSidebar extends StatelessWidget {
  final FormElement? selectedElement;
  final Function(String, Map<String, dynamic>) onPropertiesChanged;

  const PropertiesSidebar({
    Key? key,
    this.selectedElement,
    required this.onPropertiesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedElement == null) {
      return Container(
        width: 300,
        color: Colors.grey[100],
        child: const Center(
          child: Text('Select a field to edit properties'),
        ),
      );
    }

    return Container(
      width: 300,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue,
            child: Row(
              children: [
                Icon(
                  _getIconForType(selectedElement!.type),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Edit ${selectedElement!.type}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCommonProperties(),
                const SizedBox(height: 16),
                _buildTypeSpecificProperties(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common Properties',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Field Label',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: selectedElement!.properties['label'],
          ),
          onChanged: (value) {
            final newProperties = Map<String, dynamic>.from(
              selectedElement!.properties,
            );
            newProperties['label'] = value;
            onPropertiesChanged(selectedElement!.id, newProperties);
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Required'),
          value: selectedElement!.properties['required'] ?? false,
          onChanged: (value) {
            final newProperties = Map<String, dynamic>.from(
              selectedElement!.properties,
            );
            newProperties['required'] = value;
            onPropertiesChanged(selectedElement!.id, newProperties);
          },
        ),
      ],
    );
  }

  Widget _buildTypeSpecificProperties() {
    switch (selectedElement!.type) {
      case 'Text Field':
        return _buildTextFieldProperties();
      case 'Dropdown':
      case 'Radio Button':
        return _buildOptionsProperties();
      case 'Checkbox':
        return _buildCheckboxProperties();
      case 'Date Picker':
        return _buildDatePickerProperties();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextFieldProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Text Field Properties',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Placeholder Text',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: selectedElement!.properties['hint'],
          ),
          onChanged: (value) {
            final newProperties = Map<String, dynamic>.from(
              selectedElement!.properties,
            );
            newProperties['hint'] = value;
            onPropertiesChanged(selectedElement!.id, newProperties);
          },
        ),
      ],
    );
  }

  Widget _buildOptionsProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._buildOptionsList(),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Option'),
          onPressed: () {
            final options = List<String>.from(
              selectedElement!.properties['options'],
            );
            options.add('New Option');
            final newProperties = Map<String, dynamic>.from(
              selectedElement!.properties,
            );
            newProperties['options'] = options;
            onPropertiesChanged(selectedElement!.id, newProperties);
          },
        ),
      ],
    );
  }

  List<Widget> _buildOptionsList() {
    final options = List<String>.from(selectedElement!.properties['options']);
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Option ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: option),
                onChanged: (value) {
                  final newOptions = List<String>.from(
                    selectedElement!.properties['options'],
                  );
                  newOptions[index] = value;
                  final newProperties = Map<String, dynamic>.from(
                    selectedElement!.properties,
                  );
                  newProperties['options'] = newOptions;
                  onPropertiesChanged(selectedElement!.id, newProperties);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.red,
              onPressed: () {
                final newOptions = List<String>.from(
                  selectedElement!.properties['options'],
                );
                newOptions.removeAt(index);
                final newProperties = Map<String, dynamic>.from(
                  selectedElement!.properties,
                );
                newProperties['options'] = newOptions;
                onPropertiesChanged(selectedElement!.id, newProperties);
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCheckboxProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Checkbox Properties',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Default Value'),
          value: selectedElement!.value ?? false,
          onChanged: (value) {
            final newProperties = Map<String, dynamic>.from(
              selectedElement!.properties,
            );
            newProperties['defaultValue'] = value;
            onPropertiesChanged(selectedElement!.id, newProperties);
          },
        ),
      ],
    );
  }

  Widget _buildDatePickerProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Picker Properties',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Add date picker specific properties here if needed
      ],
    );
  }

  // Icon _getIconForType(String type) {
  //   switch (type) {
  //     case 'Text Field':
  //       return const Icon(Icons.text_fields);
  //     case 'Dropdown':
  //       return const Icon(Icons.arrow_drop_down_circle);
  //     case 'Checkbox':
  //       return const Icon(Icons.check_box);
  //     case 'Radio Button':
  //       return const Icon(Icons.radio_button_checked);
  //     case 'Date Picker':
  //       return const Icon(Icons.calendar_today);
  //     default:
  //       return const Icon(Icons.widgets);
  //   }
  // }
    IconData _getIconForType(String type) {
    // Changed return type to IconData
    switch (type) {
      case 'Text Field':
        return Icons.text_fields; // Return IconData directly
      case 'Dropdown':
        return Icons.arrow_drop_down_circle;
      case 'Checkbox':
        return Icons.check_box;
      case 'Radio Button':
        return Icons.radio_button_checked;
      case 'Date Picker':
        return Icons.calendar_today;
      default:
        return Icons.widgets;
    }
  }
}
