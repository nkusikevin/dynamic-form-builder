// layout.dart
import 'package:flutter/material.dart';
import '../components/sidebar.dart';
import './form_builder.dart';
import '../components/right_sidebar.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final FormBuilderState formState = FormBuilderState();
  String? selectedElementId;

  FormElement? get selectedElement {
    if (selectedElementId == null) return null;
    return formState.elements.firstWhere(
      (element) => element.id == selectedElementId,
      orElse: () => throw StateError('Element not found'), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildToolbar(),
                      Expanded(
                        child: ReorderableListView(
                          onReorder: formState.reorderElements,
                          children: [
                            if (formState.elements.isEmpty)
                              Container(
                                key: const Key('empty'),
                                height: 200,
                                child: const Center(
                                  child: Text(
                                    'Drop form elements here',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ...formState.elements.map((element) {
                              return GestureDetector(
                                key: Key(element.id),
                                onTap: () {
                                  setState(() {
                                    selectedElementId = element.id;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: element.id == selectedElementId
                                        ? Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: FormElementWidget(
                                    element: element,
                                    onDelete: () {
                                      setState(() {
                                        if (selectedElementId == element.id) {
                                          selectedElementId = null;
                                        }
                                        formState.removeElement(element.id);
                                      });
                                    },
                                    onValueChanged: (value) {
                                      setState(() {
                                        formState.updateElementValue(
                                          element.id,
                                          value,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              onAccept: (data) {
                setState(() {
                  formState.addElement(data);
                });
              },
            ),
          ),
          PropertiesSidebar(
            selectedElement: selectedElement,
            onPropertiesChanged:
                (String id, Map<String, dynamic> newProperties) {
              setState(() {
                final elementIndex = formState.elements
                    .indexWhere((element) => element.id == id);
                if (elementIndex != -1) {
                  formState.elements[elementIndex].properties = newProperties;
                }
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Form'),
            onPressed: () {
              // TODO: Implement save functionality
              print('Form elements: ${formState.elements.length}');
              print('Form data: ${formState.elements.map((e) => {
                    'type': e.type,
                    'id': e.id,
                    'label': e.label,
                    'value': e.value,
                  }).toList()}');
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
            onPressed: () {
              setState(() {
                formState.elements.clear();
                formState.notifyListeners();
              });
            },
          ),
        ],
      ),
    );
  }
}
