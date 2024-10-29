import 'package:flutter/material.dart';
import '../components/sidebar.dart';
import './form_builder.dart';
import '../components/right_sidebar.dart';
import '../models/form_model.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

class Layout extends StatefulWidget {
  final SavedForm form;

  const Layout({
    super.key,
    required this.form,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late FormBuilderState formState;
  String? selectedElementId;

  @override
  void initState() {
    super.initState();
    formState = FormBuilderState();
    _loadFormElements();
  }

  void _loadFormElements() {
    formState.elements = widget.form.elements.map((elementMap) {
      Map<String, dynamic> properties = {};
      if (elementMap['properties'] != null) {
        properties = Map<String, dynamic>.from(elementMap['properties'] as Map);
      }

      return FormElement(
        type: elementMap['type'] as String,
        id: elementMap['id'] as String,
        properties: properties,
        value: elementMap['value'],
      );
    }).toList();
  }

  FormElement? get selectedElement {
    if (selectedElementId == null) return null;
    return formState.elements.firstWhere(
      (element) => element.id == selectedElementId,
      orElse: () => throw StateError('Element not found'),
    );
  }

  void _saveForm() {
    widget.form.elements = formState.elements
        .map((element) => {
              'type': element.type,
              'id': element.id,
              'properties': element.properties,
              'value': element.value,
            })
        .toList();

    widget.form.save();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.form.title,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade400,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
            onPressed: _saveForm,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
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
                        child: DragAndDropLists(
                          children: [
                            DragAndDropList(
                              canDrag: false,
                              header: formState.elements.isEmpty
                                  ? Container(
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
                                    )
                                  : null,
                                  children: List.generate(
                                formState.elements.length,
                                (index) {
                                  final element = formState.elements[index];
                                  return DragAndDropItem(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedElementId = element.id;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border:
                                              element.id == selectedElementId
                                                  ? Border.all(
                                                      color: Colors.blue,
                                                      width: 1,
                                                    )
                                                  : null,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: FormElementWidget(
                                          
                                          key: ValueKey(element.id),
                                          element: element,
                                          onDelete: () {
                                            setState(() {
                                              if (selectedElementId ==
                                                  element.id) {
                                                selectedElementId = null;
                                              }
                                              formState
                                                  .removeElement(element.id);
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
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          
                          onItemReorder: (int oldItemIndex, int oldListIndex,
                              int newItemIndex, int newListIndex) {
                            setState(() {
                              formState.reorderElements(
                                  oldItemIndex, newItemIndex);
                            });
                          },
                          onListReorder:
                              (_, __) {}, // Not needed for single list
                          listPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          itemDivider: const Divider(
                            thickness: 2,
                            height: 2,
                            color: Colors.transparent,
                          ),
                          itemDecorationWhileDragging: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          listInnerDecoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          lastItemTargetHeight: 8,
                          addLastItemTargetHeightToTop: true,
                          contentsWhenEmpty: Container(
                            padding: const EdgeInsets.all(20),
                            child: const Center(
                              child: Text(
                                'Drop elements here to build your form',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onAcceptWithDetails: (DragTargetDetails<String> data) {
                setState(() {
                  formState.addElement(data.data);
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
            onPressed: _saveForm,
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
