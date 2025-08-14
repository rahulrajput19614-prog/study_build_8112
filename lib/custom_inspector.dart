// Imports that would be required for the code to run
import 'dart:async';
import 'dart:html' as web;
import 'dart:js_util';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Assuming these classes and services are defined elsewhere in the project.
// For a complete runnable example, they would need to be implemented.
// Here we just define them as placeholders.
class InspectorSerializationDelegate {
  final Object? service;
  final bool summaryTree;
  final int subtreeDepth;
  final bool includeProperties;
  final bool expandPropertyValues;

  const InspectorSerializationDelegate({
    this.service,
    this.summaryTree = false,
    this.subtreeDepth = 0,
    this.includeProperties = false,
    this.expandPropertyValues = false,
  });
}

class WidgetInspectorService {
  static final WidgetInspectorService instance = WidgetInspectorService();
}

/// A wrapper widget that adds a debug inspector overlay.
class CustomWidgetInspector extends StatefulWidget {
  const CustomWidgetInspector({
    super.key,
    required this.child,
    this.inspectToggle,
  });

  final Widget child;
  final bool? inspectToggle;

  static const Set<String> wrapperWidgetTypeNames = {
    'IgnorePointer',
    'Listener',
    'RawGestureDetector',
    'MouseRegion',
    'KeyedSubtree',
    'Stack',
    'Positioned',
  };

  @override
  _CustomWidgetInspectorState createState() => _CustomWidgetInspectorState();
}

class _CustomWidgetInspectorState extends State<CustomWidgetInspector> {
  RenderObject? _selectedRenderObject;
  Element? _selectedElement;
  Offset _popupPosition = Offset.zero;
  bool _showWidgetPopup = false;
  List<Map<String, dynamic>> _availableWidgets = [];
  Timer? _popupTimer;
  Offset _lastTapPosition = Offset.zero;
  final GlobalKey _childKey = GlobalKey();

  bool isInspectorEnabled = false;
  static const Set<String> meaningfulWidgetTypeNames = {
    'Text',
    'IconButton',
    'FloatingActionButton',
    'ElevatedButton',
    'TextButton',
    'OutlinedButton',
    'MaterialButton',
    'RawMaterialButton',
    'InkResponse',
    'InkWell',
    'CupertinoButton',
    'BackButton',
    'CloseButton',
    'PopupMenuButton',
    'DropdownButton',
    'DropdownButtonFormField',
    'MenuItemButton',
    'SubmenuButton',
    'MenuAnchor',
    'ButtonBar',
    'ToggleButtons',
    'Chip',
    'ActionChip',
    'FilterChip',
    'ChoiceChip',
    'InputChip',
    'RawChip',
    'Checkbox',
    'Radio',
    'Switch',
    'ExpansionTile',
    'ListTile',
    'CheckboxListTile',
    'RadioListTile',
    'SwitchListTile',
    'TextField',
    'TextFormField',
    'Image',
    'Container',
    'Card',
    'ListView',
    'GridView',
    'Column',
    'Row',
    'Stack',
    'RichText',
    'SizedBox',
    'Padding',
    'Center',
    'Align',
    'Scaffold',
    'AppBar',
    'BottomNavigationBar',
    'Drawer',
  };

  static const Set<String> listViewWidgets = {
    'ListView',
    'GridView',
  };
  
  static const Set<String> wrapperWidgetTypeNames = {
    'Listener',
    'RawGestureDetector',
    'MouseRegion',
    'KeyedSubtree',
    'Stack',
    'Positioned',
    'IgnorePointer',
    '_WidgetInspector',
    '_CustomWidgetInspectorState',
  };

  bool _isWidgetMeaningful(Element element) {
    if (element.renderObject == null) return false;
    final String typeName = element.widget.runtimeType.toString().split('<').first;
    return meaningfulWidgetTypeNames.contains(typeName) || _isCustomWidget(typeName);
  }

  bool _isCustomWidget(String widgetTypeName) {
    // Exclude core Flutter widgets, wrappers, and widgets from packages like flutter_svg
    final excludedPrefixes = {'_', 'Proxy', 'Primary', 'Local', 'Widgets', 'Material', 'Cupertino', 'Semantics', 'Size', 'Sliver', 'Decorated', 'Layout', 'KeepAlive', 'ColoredBox', 'OverflowBox', 'Focus'};
    final excludedNames = {'Container', 'Column', 'Row', 'Stack', 'ListView', 'GridView', 'SizedBox', 'Padding', 'Center', 'Align', 'Scaffold', 'AppBar', 'BottomNavigationBar', 'Drawer', 'RichText'};
    return !excludedNames.contains(widgetTypeName) && !excludedPrefixes.any((prefix) => widgetTypeName.startsWith(prefix));
  }

  List<Map<String, dynamic>> _collectMeaningfulWidgetsAtPosition(Offset globalPosition, {required bool debugMode}) {
    final List<Map<String, dynamic>> widgets = [];

    final RenderBox? root = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (root == null) return widgets;

    final result = HitTestResult();
    WidgetsBinding.instance.renderView.hitTest(result, globalPosition);

    for (final HitTestEntry entry in result.path) {
      if (entry.target is! RenderObject) continue;
      final RenderObject renderObject = entry.target as RenderObject;

      final Element? element = _findElementForRenderObject(renderObject);
      if (element == null) continue;

      final String typeName = element.widget.runtimeType.toString().split('<').first;

      if (_isWidgetMeaningful(element)) {
        final locationInfo = _getWidgetLocation(element);
        final String displayName = locationInfo['widgetName'] ?? typeName;
        widgets.add({
          'element': element,
          'renderObject': renderObject,
          'displayName': displayName,
        });
      }
    }
    return widgets;
  }

  void _handlePointerEvent(PointerDownEvent event) {
    if (!isInspectorEnabled) return;
    _handleTap(event.position);
  }

  void _handleTap(Offset globalPosition) {
    if (!isInspectorEnabled) return;

    _popupTimer?.cancel();

    final List<Map<String, dynamic>> meaningfulWidgets =
        _collectMeaningfulWidgetsAtPosition(globalPosition, debugMode: false);

    if (meaningfulWidgets.isEmpty) {
      setState(() {
        _selectedRenderObject = null;
        _showWidgetPopup = false;
        _availableWidgets = [];
      });
      return;
    }

    if (meaningfulWidgets.length > 1) {
      setState(() {
        _availableWidgets = meaningfulWidgets;
        _popupPosition = globalPosition;
        _showWidgetPopup = true;
      });
      _popupTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          _showWidgetPopup = false;
        });
      });
    } else {
      final selectedWidget = meaningfulWidgets.first;
      final Element element = selectedWidget['element'] as Element;
      _selectWidget(element);
    }
  }

  Element? _findParentListView(Element current) {
    final Set<String> listViewWidgets = {'ListView', 'GridView'};
    String currentTypeName = current.widget.runtimeType.toString().split('<').first;

    if (listViewWidgets.contains(currentTypeName)) {
      return current;
    }

    int depth = 0;
    while (current != null && depth < 50) {
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false;
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType.toString().split('<').first;

      if (listViewWidgets.contains(parentTypeName)) {
        return parent;
      }

      Set<String> stopAtWidgets = {'Scaffold', 'MaterialApp', 'CupertinoApp', 'WidgetsApp'};
      if (stopAtWidgets.contains(parentTypeName)) {
        break;
      }

      current = parent;
      depth++;
    }
    return null;
  }

  Element? _findButtonParent(Element startElement) {
    Element? current = startElement;
    Set<String> buttonWidgets = {
      'IconButton',
      'FloatingActionButton',
      'ElevatedButton',
      'TextButton',
      'OutlinedButton',
      'MaterialButton',
      'RawMaterialButton',
      'InkResponse',
      'InkWell',
      'CupertinoButton',
      'BackButton',
      'CloseButton',
      'PopupMenuButton',
      'DropdownButton',
      'DropdownButtonFormField',
      'MenuItemButton',
      'SubmenuButton',
      'MenuAnchor',
      'ButtonBar',
      'ToggleButtons',
      'Chip',
      'ActionChip',
      'FilterChip',
      'ChoiceChip',
      'InputChip',
      'RawChip',
      'Checkbox',
      'Radio',
      'Switch',
      'ExpansionTile',
      'ListTile',
      'CheckboxListTile',
      'RadioListTile',
      'SwitchListTile',
      '_ElevatedButtonWithIcon',
      '_TextButtonWithIcon',
      '_OutlinedButtonWithIcon',
      '_FloatingActionButtonType',
      '_IconButtonM3',
      '_InkResponseStateWidget',
      '_ParentInkResponseProvider',
    };

    String currentTypeName = current.widget.runtimeType.toString().split('<').first;
    if (buttonWidgets.contains(currentTypeName)) {
      return current;
    }

    int searchDepth = 0;
    while (current != null && searchDepth < 25) {
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false;
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType.toString().split('<').first;

      if (buttonWidgets.contains(parentTypeName)) {
        return parent;
      }

      Set<String> stopAtWidgets = {
        'Scaffold',
        'MaterialApp',
        'CupertinoApp',
        'WidgetsApp',
        'AppBar',
        'BottomNavigationBar',
        'Drawer',
      };
      if (stopAtWidgets.contains(parentTypeName)) {
        break;
      }

      current = parent;
      searchDepth++;
    }
    return null;
  }

  Element? _findCheckboxParent(Element startElement) {
    Element? current = startElement;
    Set<String> checkboxWidgets = {
      'Checkbox',
      'Radio',
      'Switch',
      'CheckboxListTile',
      'RadioListTile',
      'SwitchListTile',
    };
    String currentTypeName = current.widget.runtimeType.toString().split('<').first;
    if (checkboxWidgets.contains(currentTypeName)) {
      return current;
    }

    int searchDepth = 0;
    while (current != null && searchDepth < 5) {
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false;
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType.toString().split('<').first;

      if (checkboxWidgets.contains(parentTypeName)) {
        return parent;
      }

      current = parent;
      searchDepth++;
    }
    return null;
  }

  Element? _findCustomWidgetParent(Element startElement) {
    Element? current = startElement;
    int searchDepth = 0;
    while (current != null && searchDepth < 10) {
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false;
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType.toString().split('<').first;

      if (_isCustomWidget(parentTypeName)) {
        return parent;
      }

      current = parent;
      searchDepth++;
    }
    return null;
  }

  Element? _findFormFieldParent(Element startElement) {
    Element? current = startElement;
    Set<String> formFieldWidgets = {
      'TextFormField',
      'TextField',
      'DropdownButtonFormField',
      'CheckboxListTile',
      'RadioListTile',
      'SwitchListTile',
    };
    String currentTypeName = current.widget.runtimeType.toString().split('<').first;
    if (formFieldWidgets.contains(currentTypeName)) {
      return current;
    }

    while (current != null) {
      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false;
      });

      if (parent == null) break;

      String parentTypeName = parent!.widget.runtimeType.toString().split('<').first;

      if (formFieldWidgets.contains(parentTypeName)) {
        return parent;
      }

      Set<String> stopAtWidgets = {
        'Column',
        'Row',
        'Stack',
        'ListView',
        'GridView',
        'Scaffold',
        'Card',
      };
      if (stopAtWidgets.contains(parentTypeName)) {
        break;
      }

      current = parent;
    }
    return null;
  }

  bool _renderObjectContainsPosition(
    RenderObject renderObject,
    Offset globalPosition,
  ) {
    try {
      final Matrix4 transform = renderObject.getTransformTo(null);
      final Matrix4? inverse = Matrix4.tryInvert(transform);
      if (inverse == null) return false;

      final Offset localPosition = MatrixUtils.transformPoint(
        inverse,
        globalPosition,
      );
      final Rect bounds = renderObject.semanticBounds;
      return bounds.contains(localPosition);
    } catch (e) {
      return false;
    }
  }

  Element? _findMeaningfulChildOfScrollWidget(Element scrollElement) {
    Element? meaningfulChild;
    Set<String> layoutWidgetsForScrollViews = {
      'Column',
      'Row',
      'Stack',
      'Container',
      'Card',
      'ListView',
      'GridView',
    };

    void searchForLayoutChild(Element element, int depth) {
      if (meaningfulChild != null || depth > 15) {
        return;
      }
      element.visitChildren((child) {
        if (meaningfulChild != null) return;
        String childTypeName = child.widget.runtimeType.toString().split('<').first;
        if (layoutWidgetsForScrollViews.contains(childTypeName)) {
          meaningfulChild = child;
          return;
        }
        searchForLayoutChild(child, depth + 1);
      });
    }

    searchForLayoutChild(scrollElement, 0);

    if (meaningfulChild == null) {
      void searchForAnyMeaningful(Element element, int depth) {
        if (meaningfulChild != null || depth > 15) return;
        element.visitChildren((child) {
          if (meaningfulChild != null) return;
          if (_isWidgetMeaningful(child)) {
            meaningfulChild = child;
            return;
          }
          searchForAnyMeaningful(child, depth + 1);
        });
      }
      searchForAnyMeaningful(scrollElement, 0);
    }
    return meaningfulChild;
  }

  void _selectWidget(Element element) {
    _popupTimer?.cancel();
    setState(() {
      _selectedElement = element;
      _selectedRenderObject = element.renderObject;
      _showWidgetPopup = false;
    });

    try {
      var locationInfo = _getWidgetLocation(element);
      var location = locationInfo['location'] ?? '';
      var widgetName = locationInfo['widgetName'] ?? '';
      var matchingElement = locationInfo['matchingElement'];

      if (matchingElement != null && matchingElement is Element) {
        var parentWidgetName = _getParentWidgetType(matchingElement);
        var properties = _extractWidgetProperties(matchingElement, widgetName);
        if (location.isNotEmpty && widgetName.isNotEmpty) {
          var widgetInfo = <String, dynamic>{};
          widgetInfo['widgetName'] = widgetName;
          widgetInfo['parentWidgetName'] = parentWidgetName;
          widgetInfo['location'] = location;
          widgetInfo['props'] = properties;
          _sendWidgetInformation(widgetInfo);
        }
      }
    } catch (err) {
      // Silent error handling
    }
  }

  Widget _buildWidgetSelectionPopup() {
    final displayWidgets = _availableWidgets.take(3).toList();
    double left = _popupPosition.dx;
    double top = _popupPosition.dy + 15;

    final screenSize = MediaQuery.maybeOf(context)?.size ?? Size(800, 600);
    double maxTextWidth = 80.0;
    for (var widget in displayWidgets) {
      String displayName = widget['displayName'] as String;
      double textWidth = displayName.length * 6.0 + 16.0;
      maxTextWidth = math.max(maxTextWidth, textWidth);
    }
    final popupWidth = math.min(maxTextWidth, 200.0);
    const itemHeight = 28.0;
    final popupHeight = displayWidgets.length * itemHeight;
    left = left - (popupWidth / 2);

    if (left + popupWidth > screenSize.width) {
      left = screenSize.width - popupWidth - 10;
    }
    if (left < 10) {
      left = 10;
    }
    if (top + popupHeight > screenSize.height) {
      top = _popupPosition.dy - popupHeight - 15;
    }
    if (top < 10) top = 10;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        ignoring: false,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: popupWidth,
            decoration: BoxDecoration(
              color: Color(0xFF0a0a0a),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Color.fromRGBO(255, 255, 255, 0.16),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: displayWidgets.asMap().entries.map((entry) {
                final index = entry.key;
                final widgetData = entry.value;
                final element = widgetData['element'] as Element;
                final displayName = widgetData['displayName'] as String;
                return InkWell(
                  onTap: () => _selectWidget(element),
                  child: Container(
                    height: itemHeight,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: index < displayWidgets.length - 1
                          ? Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(255, 255, 255, 0.08),
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _listenEvent();
  }

  @override
  void dispose() {
    _popupTimer?.cancel();
    super.dispose();
  }

  _listenEvent() {
    web.window.addEventListener(
      'message',
      (web.Event event) {
        try {
          final messageEvent = event as web.MessageEvent;
          if (messageEvent.data != null) {
            final data = dartify(messageEvent.data);
            if (data is Map &&
                data.containsKey('inspectToggle') &&
                data['inspectToggle'] is bool) {
              isInspectorEnabled = data['inspectToggle'];
              setState(() {});
            }
          }
        } catch (e) {
          // print('error listening to inspectToggle message: $e');
        }
      }.toJS,
    );
  }

  DateTime? _lastHoverTime;
  static const Duration _hoverThrottleDelay = Duration(milliseconds: 100);

  void _handleHover(PointerHoverEvent event) {
    if (!isInspectorEnabled) return;
    final now = DateTime.now();
    if (_lastHoverTime != null &&
        now.difference(_lastHoverTime!) < _hoverThrottleDelay) {
      return;
    }
    _lastHoverTime = now;

    if (_showWidgetPopup) {
      final distance = (event.position - _popupPosition).distance;
      if (distance > 100) {
        _popupTimer?.cancel();
        setState(() {
          _showWidgetPopup = false;
        });
      }
      return;
    }

    List<Map<String, dynamic>> meaningfulWidgets =
        _collectMeaningfulWidgetsAtPosition(event.position, debugMode: false);

    if (meaningfulWidgets.isNotEmpty) {
      final selectedWidget = meaningfulWidgets.first;
      final Element selectedElement = selectedWidget['element'] as Element;
      final RenderObject? selectedRenderObject = selectedElement.renderObject;

      if (_selectedRenderObject != selectedRenderObject) {
        setState(() {
          _selectedRenderObject = selectedRenderObject;
          _selectedElement = selectedElement;
        });
      }
    } else if (_selectedRenderObject != null) {
      setState(() {
        _selectedRenderObject = null;
        _selectedElement = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (isInspectorEnabled && _selectedRenderObject != null) {
            setState(() {
              _selectedRenderObject = null;
              _selectedElement = null;
            });
          }
          return false;
        },
        child: Stack(
          children: [
            MouseRegion(
              onExit: (_) {
                if (isInspectorEnabled) {
                  setState(() {
                    _selectedRenderObject = null;
                    _selectedElement = null;
                  });
                }
              },
              onHover: isInspectorEnabled ? _handleHover : null,
              child: KeyedSubtree(
                key: _childKey,
                child: Stack(
                  children: [
                    widget.child,
                    if (isInspectorEnabled)
                      Positioned.fill(
                        child: Listener(
                          behavior: HitTestBehavior.translucent,
                          onPointerDown: _handlePointerEvent,
                          onPointerHover: _handleHover,
                          child: RawGestureDetector(
                            behavior: HitTestBehavior.translucent,
                            gestures: <Type, GestureRecognizerFactory>{
                              TapGestureRecognizer:
                                  GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                                      () => TapGestureRecognizer(), (
                                        TapGestureRecognizer instance,
                                      ) {
                                instance.onTapDown = (TapDownDetails details) {
                                  _lastTapPosition = details.globalPosition;
                                };
                                instance.onTap = () {
                                  _handleTap(_lastTapPosition);
                                };
                              }),
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isInspectorEnabled && _selectedRenderObject != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _InspectorOverlayPainter(
                      selectedRenderObject: _selectedRenderObject!,
                      selectedElement: _selectedElement,
                    ),
                  ),
                ),
              ),
            if (isInspectorEnabled && _showWidgetPopup)
              _buildWidgetSelectionPopup(),
          ],
        ),
      ),
    );
  }

  RenderObject? _findRenderObjectAtPosition(
    Offset position,
    RenderObject root,
  ) {
    final List<RenderObject> hits = <RenderObject>[];
    _hitTestHelper(hits, position, root, root.getTransformTo(null));
    if (hits.isEmpty) return null;
    hits.sort((RenderObject a, RenderObject b) {
      final Size sizeA = a.semanticBounds.size;
      final Size sizeB = b.semanticBounds.size;
      return (sizeA.width * sizeA.height).compareTo(sizeB.width * sizeB.height);
    });
    return hits.first;
  }

  bool _hitTestHelper(
    List<RenderObject> hits,
    Offset position,
    RenderObject object,
    Matrix4 transform,
  ) {
    bool hit = false;
    final Matrix4? inverse = Matrix4.tryInvert(transform);
    if (inverse == null) {
      return false;
    }
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);
    final List<DiagnosticsNode> children = object.debugDescribeChildren();
    for (int i = children.length - 1; i >= 0; i -= 1) {
      final DiagnosticsNode diagnostics = children[i];
      if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
          diagnostics.value is! RenderObject) {
        continue;
      }
      final RenderObject child = diagnostics.value! as RenderObject;
      final Rect? paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition)) {
        continue;
      }
      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(hits, position, child, childTransform)) {
        hit = true;
      }
    }
    final Rect bounds = object.semanticBounds;
    if (bounds.contains(localPosition)) {
      hit = true;
      hits.add(object);
    }
    return hit;
  }

  Element? _findElementForRenderObject(RenderObject renderObject) {
    Element? result;
    void visitor(Element element) {
      if (element.renderObject == renderObject) {
        result = element;
        return;
      }
      element.visitChildren(visitor);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitor);
    return result;
  }
}

class _InspectorOverlayPainter extends CustomPainter {
  final RenderObject selectedRenderObject;
  final Element? selectedElement;

  _InspectorOverlayPainter({
    required this.selectedRenderObject,
    required this.selectedElement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!selectedRenderObject.attached) return;

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(128, 128, 128, 255);

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color.fromARGB(128, 64, 64, 128);

    final Matrix4 transform = selectedRenderObject.getTransformTo(null);
    final Rect bounds = selectedRenderObject.semanticBounds;
    canvas.save();
    canvas.transform(transform.storage);
    final double deflateAmount = bounds.width < 40 || bounds.height < 40 ? 0.0 : 0.5;
    final Rect fillRect = bounds.deflate(deflateAmount);
    final Rect borderRect = bounds.deflate(deflateAmount);

    if (fillRect.width > 0 && fillRect.height > 0) {
      canvas.drawRect(fillRect, fillPaint);
      canvas.drawRect(borderRect, borderPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InspectorOverlayPainter oldDelegate) {
    return selectedRenderObject != oldDelegate.selectedRenderObject ||
        selectedElement != oldDelegate.selectedElement;
  }
}

String _getParentWidgetType(Element element) {
  Element? parent;
  element.visitAncestorElements((Element ancestor) {
    parent = ancestor;
    return false;
  });
  return parent?.widget.runtimeType.toString() ?? 'None';
}

class WidgetLocationInfo {
  final String? location;
  final String? widgetName;
  final Element? matchingElement;
  final bool isValid;
  final String? error;

  const WidgetLocationInfo({
    this.location,
    this.widgetName,
    this.matchingElement,
    this.isValid = false,
    this.error,
  });

  factory WidgetLocationInfo.success({
    required String location,
    required String widgetName,
    required Element matchingElement,
  }) {
    return WidgetLocationInfo(
      location: location,
      widgetName: widgetName,
      matchingElement: matchingElement,
      isValid: true,
    );
  }

  factory WidgetLocationInfo.failure(String error) {
    return WidgetLocationInfo(isValid: false, error: error);
  }

  Map<String, dynamic> toLegacyMap() {
    return {
      'location': location,
      'widgetName': widgetName,
      'matchingElement': matchingElement,
    };
  }
}

class LocationFinderConfig {
  final Set<String> excludedPaths;
  final int maxAncestorDepth;
  final bool skipWrapperWidgets;
  final bool debugMode;

  const LocationFinderConfig({
    this.excludedPaths = const {
      '/packages/flutter',
      'pub.dev',
      '/flutter_web_plugins',
      '/flutter_test',
      '/.dart_tool',
      '/build/',
    },
    this.maxAncestorDepth = 50,
    this.skipWrapperWidgets = true,
    this.debugMode = false,
  });

  bool shouldExcludePath(String filePath) {
    if (filePath.isEmpty) return true;
    return excludedPaths.any((excluded) => filePath.contains(excluded));
  }
}

class WidgetLocationFinder {
  final LocationFinderConfig config;

  const WidgetLocationFinder({this.config = const LocationFinderConfig()});

  WidgetLocationInfo findLocation(Element element) {
    try {
      Element? targetElement = config.skipWrapperWidgets
          ? _skipToNonWrapperWidget(element)
          : element;

      if (targetElement == null) {
        return WidgetLocationInfo.failure('No non-wrapper widget found');
      }

      WidgetLocationInfo? result = _extractLocationFromElement(targetElement);
      if (result != null && result.isValid) {
        return result;
      }

      result = _searchAncestorsForLocation(targetElement);
      if (result != null && result.isValid) {
        return result;
      }

      return WidgetLocationInfo.failure(
        'No valid location found in element tree',
      );
    } catch (e) {
      return WidgetLocationInfo.failure(
        'Exception during location finding: $e',
      );
    }
  }

  Element? _skipToNonWrapperWidget(Element element) {
    Element? current = element;
    int depth = 0;
    const maxWrapperDepth = 10;
    while (current != null && depth < maxWrapperDepth) {
      String widgetTypeName = current.widget.runtimeType.toString().split('<').first;
      if (!CustomWidgetInspector.wrapperWidgetTypeNames.contains(
        widgetTypeName,
      )) {
        return current;
      }
      Element? childElement;
      current.visitChildren((child) {
        childElement ??= child;
      });
      current = childElement;
      depth++;
    }
    return current;
  }

  WidgetLocationInfo? _extractLocationFromElement(Element element) {
    try {
      DiagnosticsNode node = element.toDiagnosticsNode();
      var delegate = InspectorSerializationDelegate(
        service: WidgetInspectorService.instance,
        summaryTree: true,
        subtreeDepth: 1,
        includeProperties: true,
        expandPropertyValues: true,
      );

      final Map<String, Object?> json = node.toJsonMap(delegate);
      if (!json.containsKey('creationLocation')) {
        return null;
      }

      final Map creationLocation = json['creationLocation'] as Map;
      final String filePath = creationLocation['file']?.toString() ?? '';
      final String widgetName = creationLocation['name']?.toString() ?? '';

      if (config.shouldExcludePath(filePath)) {
        return null;
      }

      final String line = creationLocation['line']?.toString() ?? '0';
      final String column = creationLocation['column']?.toString() ?? '0';

      if (widgetName.isEmpty) {
        return null;
      }

      final String location = '$filePath:$line:$column';
      return WidgetLocationInfo.success(
        location: location,
        widgetName: widgetName,
        matchingElement: element,
      );
    } catch (e) {
      return null;
    }
  }

  WidgetLocationInfo? _searchAncestorsForLocation(Element startElement) {
    WidgetLocationInfo? result;
    int depth = 0;
    startElement.visitAncestorElements((Element ancestor) {
      if (depth >= config.maxAncestorDepth) {
        return false;
      }
      result = _extractLocationFromElement(ancestor);
      depth++;
      return result == null || !result!.isValid;
    });
    return result;
  }
}

Map<String, dynamic> _getWidgetLocation(Element element) {
  const finder = WidgetLocationFinder();
  final result = finder.findLocation(element);
  return result.toLegacyMap();
}

Element? _findInternalTextField(Element textFormFieldElement) {
  Element? textFieldElement;
  void searchForTextField(Element element, int depth) {
    if (textFieldElement != null || depth > 10) {
      return;
    }
    element.visitChildren((child) {
      if (textFieldElement != null) return;
      String childTypeName = child.widget.runtimeType.toString().split('<').first;
      if (childTypeName == 'TextField') {
        textFieldElement = child;
        return;
      }
      searchForTextField(child, depth + 1);
    });
  }
  searchForTextField(textFormFieldElement, 0);
  return textFieldElement;
}

Map<String, dynamic> _extractTextFieldProperties(
  TextField textFieldWidget,
  Element element,
) {
  final Map<String, dynamic> properties = {};
  properties['text'] = textFieldWidget.controller?.text ?? 'null';
  properties['style'] = getTextStyle(textFieldWidget.style, element);
  properties['readOnly'] = textFieldWidget.readOnly.toString();
  properties['obscureText'] = textFieldWidget.obscureText.toString();
  properties['autocorrect'] = textFieldWidget.autocorrect.toString();
  properties['keyboardType'] = _getKeyboardTypeDetails(
    textFieldWidget.keyboardType,
  );
  properties['textInputAction'] = textFieldWidget.textInputAction?.toString() ?? 'null';
  properties['maxLines'] = textFieldWidget.maxLines?.toString() ?? 'null';
  properties['maxLength'] = textFieldWidget.maxLength?.toString() ?? 'null';
  properties['autofocus'] = textFieldWidget.autofocus.toString();
  properties['textAlign'] = textFieldWidget.textAlign.toString();
  properties['textCapitalization'] = textFieldWidget.textCapitalization.toString();
  properties['enableSuggestions'] = textFieldWidget.enableSuggestions.toString();
  properties['showCursor'] = textFieldWidget.showCursor?.toString() ?? 'null';
  properties['cursorWidth'] = textFieldWidget.cursorWidth.toString();
  properties['cursorHeight'] = textFieldWidget.cursorHeight?.toString() ?? 'null';
  properties['cursorColor'] = textFieldWidget.cursorColor != null
      ? colorToHex(textFieldWidget.cursorColor!)
      : 'null';
  properties['decoration'] = {
    'border': textFieldWidget.decoration?.border.toString() ?? 'null',
    'enabledBorder': textFieldWidget.decoration?.enabledBorder.toString() ?? 'null',
    'focusedBorder': textFieldWidget.decoration?.focusedBorder.toString() ?? 'null',
    'disabledBorder': textFieldWidget.decoration?.disabledBorder.toString() ?? 'null',
    'errorBorder': textFieldWidget.decoration?.errorBorder.toString() ?? 'null',
    'focusedErrorBorder': textFieldWidget.decoration?.focusedErrorBorder.toString() ?? 'null',
    'fillColor': textFieldWidget.decoration?.fillColor != null
        ? colorToHex(textFieldWidget.decoration!.fillColor!)
        : 'null',
    'filled': textFieldWidget.decoration?.filled.toString() ?? 'null',
    'hintText': textFieldWidget.decoration?.hintText.toString() ?? 'null',
    'hintStyle': getTextStyle(textFieldWidget.decoration?.hintStyle, element),
    'labelText': textFieldWidget.decoration?.labelText.toString() ?? 'null',
    'labelStyle': getTextStyle(textFieldWidget.decoration?.labelStyle, element),
    'helperText': textFieldWidget.decoration?.helperText.toString() ?? 'null',
    'helperStyle': getTextStyle(
      textFieldWidget.decoration?.helperStyle,
      element,
    ),
    'errorText': textFieldWidget.decoration?.errorText.toString() ?? 'null',
    'errorStyle': getTextStyle(textFieldWidget.decoration?.errorStyle, element),
    'prefixIcon': textFieldWidget.decoration?.prefixIcon.toString() ?? 'null',
    'prefixIconConstraints': textFieldWidget.decoration?.prefixIconConstraints.toString() ?? 'null',
    'suffixIcon': textFieldWidget.decoration?.suffixIcon.toString() ?? 'null',
    'suffixIconConstraints': textFieldWidget.decoration?.suffixIconConstraints.toString() ?? 'null',
    'counterText': textFieldWidget.decoration?.counterText.toString() ?? 'null',
    'counterStyle': getTextStyle(
      textFieldWidget.decoration?.counterStyle,
      element,
    ),
  };
  return properties;
}

String _getKeyboardTypeDetails(TextInputType? keyboardType) {
  if (keyboardType == null) return "null";
  String typeName = 'unknown';
  if (keyboardType == TextInputType.text) {
    typeName = 'TextInputType.text';
  } else if (keyboardType == TextInputType.number) {
    typeName = 'TextInputType.number';
  } else if (keyboardType == TextInputType.emailAddress) {
    typeName = 'TextInputType.emailAddress';
  } else if (keyboardType == TextInputType.datetime) {
    typeName = 'TextInputType.datetime';
  } else if (keyboardType == TextInputType.multiline) {
    typeName = 'TextInputType.multiline';
  } else if (keyboardType == TextInputType.phone) {
    typeName = 'TextInputType.phone';
  } else if (keyboardType == TextInputType.url) {
    typeName = 'TextInputType.url';
  } else if (keyboardType == TextInputType.visiblePassword) {
    typeName = 'TextInputType.visiblePassword';
  } else if (keyboardType == TextInputType.name) {
    typeName = 'TextInputType.name';
  } else if (keyboardType == TextInputType.streetAddress) {
    typeName = 'TextInputType.streetAddress';
  } else if (keyboardType == TextInputType.none) {
    typeName = 'TextInputType.none';
  }
  return typeName;
}

Map<String, dynamic> _extractWidgetProperties(
  Element element,
  String widgetName,
) {
  final Map<String, dynamic> properties = {};
  switch (widgetName) {
    case 'Text':
      final widget = element.widget as Text;
      properties['type'] = 'Text';
      properties['text'] = widget.data;
      properties['style'] = getTextStyle(widget.style, element);
      properties['textAlign'] = widget.textAlign?.toString() ?? 'null';
      break;

    case 'ElevatedButton':
    case 'OutlinedButton':
    case 'TextButton':
      final buttonWidget = element.widget as ButtonStyleButton;
      properties['type'] = widgetName;
      properties['enabled'] = (buttonWidget.onPressed != null).toString();
      properties['autofocus'] = buttonWidget.autofocus.toString();
      properties['clipBehavior'] = buttonWidget.clipBehavior.toString();
      final Widget? child = buttonWidget.child;
      if (child is Text) {
        properties['text'] = child.data ?? 'null';
        properties['childType'] = 'Text';
      } else if (child is Icon) {
        properties['text'] = 'null';
        properties['childType'] = 'Icon';
        properties['iconData'] = child.icon.toString();
      } else if (child is Row) {
        properties['childType'] = 'Row';
        properties['text'] = 'null';
      } else {
        properties['text'] = 'null';
        properties['childType'] = child?.runtimeType.toString() ?? 'null';
      }
      final buttonStyleProperties = getButtonStyle(
        buttonWidget.style,
        element,
        widgetName,
      );
      properties.addAll(buttonStyleProperties);
      break;

    case 'Icon':
      final widget = element.widget as Icon;
      properties['type'] = 'Icon';
      properties['icon'] = widget.icon.toString();
      properties['color'] = widget.color != null
          ? colorToHex(widget.color!)
          : 'null';
      properties['size'] = widget.size?.toString() ?? 'null';
      break;

    case 'Container':
      final widget = element.widget as Container;
      properties['type'] = 'Container';
      properties['color'] = widget.color != null
          ? colorToHex(widget.color!)
          : 'null';
      properties['width'] = widget.constraints?.maxWidth.toString() ?? 'null';
      properties['height'] = widget.constraints?.maxHeight.toString() ?? 'null';
      properties['padding'] = widget.padding?.toString() ?? 'null';
      properties['margin'] = widget.margin?.toString() ?? 'null';
      if (widget.decoration is BoxDecoration) {
        final boxDecoration = widget.decoration as BoxDecoration;
        properties['decoration'] = {
          'color': boxDecoration.color != null
              ? colorToHex(boxDecoration.color!)
              : 'null',
          'border': _getBorderDetails(boxDecoration.border as Border?),
          'borderRadius': _getBorderRadiusDetails(boxDecoration.borderRadius),
          'boxShadow': _getBoxShadowDetails(boxDecoration.boxShadow),
          'gradient': _getGradientDetails(boxDecoration.gradient),
          'image': _getDecorationImageDetails(boxDecoration.image),
          'shape': boxDecoration.shape.toString(),
        };
      }
      properties['alignment'] = widget.alignment?.toString() ?? 'null';
      break;

    case 'TextField':
      final widget = element.widget as TextField;
      properties['type'] = widgetName;
      final textFieldProperties = _extractTextFieldProperties(widget, element);
      properties.addAll(textFieldProperties);
      break;

    case 'TextFormField':
      final widget = element.widget as TextFormField;
      properties['type'] = widgetName;
      properties['initialValue'] = widget.initialValue ?? 'null';
      properties['text'] = widget.controller?.text ?? 'null';
      properties['enabled'] = widget.enabled.toString();
      properties['autovalidateMode'] = widget.autovalidateMode.toString();
      properties['errorText'] = widget.errorText ?? 'null';
      Element? textFieldElement = _findInternalTextField(element);
      if (textFieldElement != null) {
        final textFieldWidget = textFieldElement.widget as TextField;
        final textFieldProperties = _extractTextFieldProperties(
          textFieldWidget,
          element,
        );
        properties.addAll(textFieldProperties);
      }
      break;

    case 'Column':
    case 'Row':
      final widget = element.widget as Flex;
      properties['type'] = widget.runtimeType.toString();
      properties['mainAxisAlignment'] = widget.mainAxisAlignment.toString();
      properties['crossAxisAlignment'] = widget.crossAxisAlignment.toString();
      properties['mainAxisSize'] = widget.mainAxisSize.toString();
      // widget.spacing is not a property of Flex, this is likely a mistake from the original code
      break;
      
    case 'RichText':
      final widget = element.widget as RichText;
      properties['type'] = 'RichText';
      properties['textAlign'] = widget.textAlign.toString();
      properties['maxLines'] = widget.maxLines?.toString() ?? 'null';
      properties['textSpan'] = _extractTextSpanDetails(
        widget.text as TextSpan,
        element,
        null,
      );
      break;

    case 'ListTile':
      final widget = element.widget as ListTile;
      properties['type'] = 'ListTile';
      properties['title'] = widget.title is Text
          ? (widget.title as Text).data
          : 'null';
      properties['subtitle'] = widget.subtitle is Text
          ? (widget.subtitle as Text).data
          : 'null';
      properties['leading'] = widget.leading.runtimeType.toString();
      properties['trailing'] = widget.trailing.runtimeType.toString();
      break;

    case 'Checkbox':
      final widget = element.widget as Checkbox;
      final defaultStyle = Theme.of(element).checkboxTheme;
      properties['type'] = 'Checkbox';
      properties['value'] = widget.value.toString();
      properties['tristate'] = widget.tristate.toString();
      final activeColor = defaultStyle.fillColor?.resolve({
        MaterialState.selected
      });
      properties['activeColor'] = widget.activeColor != null
          ? colorToHex(widget.activeColor!)
          : activeColor != null
              ? colorToHex(activeColor)
              : 'null';
      final checkColor = defaultStyle.checkColor?.resolve({});
      properties['checkColor'] = widget.checkColor != null
          ? colorToHex(widget.checkColor!)
          : checkColor != null
              ? colorToHex(checkColor)
              : 'null';
      final defaultSide = defaultStyle.side;
      properties['border'] = widget.side != null
          ? _getBorderSideDetails(widget.side!)
          : defaultSide != null
              ? _getBorderSideDetails(defaultSide)
              : 'null';
      final defaultShape = defaultStyle.shape;
      properties['shape'] = widget.shape != null
          ? _getShapeDetails(widget.shape!)
          : defaultShape != null
              ? _getShapeDetails(defaultShape)
              : 'null';
      break;

    case 'Switch':
      final widget = element.widget as Switch;
      final defaultStyle = Theme.of(element).switchTheme;
      properties['type'] = 'Switch';
      properties['value'] = widget.value.toString();
      final defaultActiveColor = defaultStyle.thumbColor?.resolve({
        MaterialState.selected
      });
      properties['activeColor'] = widget.activeColor != null
          ? colorToHex(widget.activeColor!)
          : defaultActiveColor != null
              ? colorToHex(defaultActiveColor)
              : 'null';
      final defaultInactiveThumbColor = defaultStyle.thumbColor?.resolve({});
      properties['inactiveThumbColor'] = widget.inactiveThumbColor != null
          ? colorToHex(widget.inactiveThumbColor!)
          : defaultInactiveThumbColor != null
              ? colorToHex(defaultInactiveThumbColor)
              : 'null';
      final defaultActiveTrackColor = defaultStyle.trackColor?.resolve({
        MaterialState.selected
      });
      properties['activeTrackColor'] = widget.activeTrackColor != null
          ? colorToHex(widget.activeTrackColor!)
          : defaultActiveTrackColor != null
              ? colorToHex(defaultActiveTrackColor)
              : 'null';
      final defaultInactiveTrackColor = defaultStyle.trackColor?.resolve({});
      properties['inactiveTrackColor'] = widget.inactiveTrackColor != null
          ? colorToHex(widget.inactiveTrackColor!)
          : defaultInactiveTrackColor != null
              ? colorToHex(defaultInactiveTrackColor)
              : 'null';
      final defaultPadding = defaultStyle.padding?.resolve({});
      properties['padding'] = widget.padding != null
          ? widget.padding.toString()
          : defaultPadding != null
              ? defaultPadding.toString()
              : 'null';
      break;

    case 'Radio':
      final widget = element.widget as Radio;
      final defaultStyle = Theme.of(element).radioTheme;
      properties['type'] = 'Radio';
      properties['value'] = widget.value.toString();
      properties['groupValue'] = widget.groupValue.toString();
      final activeColor = defaultStyle.fillColor?.resolve({
        MaterialState.selected
      });
      properties['activeColor'] = widget.activeColor != null
          ? colorToHex(widget.activeColor!)
          : activeColor != null
              ? colorToHex(activeColor)
              : 'null';
      properties['splashRadius'] = widget.splashRadius != null
          ? widget.splashRadius.toString()
          : defaultStyle.splashRadius != null
              ? defaultStyle.splashRadius.toString()
              : 'kRadialReactionRadius'; // Assuming kRadialReactionRadius is a constant
      break;

    default:
      properties['type'] = widgetName;
      properties['info'] =
          'There are no editable properties available for this widget.';
      break;
  }
  return properties;
}

Map<String, dynamic> getTextStyle(TextStyle? style, BuildContext context) {
  final defaultStyle = DefaultTextStyle.of(context).style;
  return {
    'color': style?.color != null
        ? colorToHex(style!.color!)
        : (defaultStyle.color != null
            ? colorToHex(defaultStyle.color!)
            : 'null'),
    'fontSize': style?.fontSize?.round().toString() ??
        defaultStyle.fontSize?.round().toString() ??
        'null',
    'backgroundColor': style?.backgroundColor != null
        ? colorToHex(style!.backgroundColor!)
        : (defaultStyle.backgroundColor != null
            ? colorToHex(defaultStyle.backgroundColor!)
            : 'null'),
    'fontWeight': style?.fontWeight?.toString() ??
        defaultStyle.fontWeight?.toString() ??
        'null',
    'fontStyle': style?.fontStyle?.toString() ??
        defaultStyle.fontStyle?.toString() ??
        'null',
    'fontFamily': style?.fontFamily ?? defaultStyle.fontFamily ?? 'null',
    'letterSpacing': style?.letterSpacing?.toString() ??
        defaultStyle.letterSpacing?.toString() ??
        'null',
    'wordSpacing': style?.wordSpacing?.toString() ??
        defaultStyle.wordSpacing?.toString() ??
        'null',
    'textBaseline': style?.textBaseline?.toString() ??
        defaultStyle.textBaseline?.toString() ??
        'null',
    'height': style?.height?.toString() ?? defaultStyle.height?.toString() ?? 'null',
    'overflow': style?.overflow?.toString() ??
        defaultStyle.overflow?.toString() ??
        'null',
  };
}

Map<String, dynamic> getButtonStyle(
  ButtonStyle? style,
  BuildContext context,
  String buttonType,
) {
  ButtonStyle? defaultStyle;
  switch (buttonType) {
    case 'ElevatedButton':
      defaultStyle = Theme.of(context).elevatedButtonTheme.style;
      break;
    case 'OutlinedButton':
      defaultStyle = Theme.of(context).outlinedButtonTheme.style;
      break;
    case 'TextButton':
      defaultStyle = Theme.of(context).textButtonTheme.style;
      break;
  }
  T? resolveWithFallback<T>(
    WidgetStateProperty<T>? widgetProperty,
    WidgetStateProperty<T>? defaultProperty,
  ) {
    final resolved = widgetProperty?.resolve({});
    if (resolved != null) return resolved;
    return defaultProperty?.resolve({});
  }

  return {
    'backgroundColor': () {
      final color = resolveWithFallback(
        style?.backgroundColor,
        defaultStyle?.backgroundColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'foregroundColor': () {
      final color = resolveWithFallback(
        style?.foregroundColor,
        defaultStyle?.foregroundColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'overlayColor': () {
      final color = resolveWithFallback(
        style?.overlayColor,
        defaultStyle?.overlayColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'shadowColor': () {
      final color = resolveWithFallback(
        style?.shadowColor,
        defaultStyle?.shadowColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'surfaceTintColor': () {
      final color = resolveWithFallback(
        style?.surfaceTintColor,
        defaultStyle?.surfaceTintColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'iconColor': () {
      final color = resolveWithFallback(
        style?.iconColor,
        defaultStyle?.iconColor,
      );
      return color != null ? colorToHex(color) : 'null';
    }(),
    'elevation': () {
      final elevation = resolveWithFallback(
        style?.elevation,
        defaultStyle?.elevation,
      );
      return elevation?.toString() ?? 'null';
    }(),
    'padding': () {
      final padding = resolveWithFallback(
        style?.padding,
        defaultStyle?.padding,
      );
      return padding?.toString() ?? 'null';
    }(),
    'minimumSize': () {
      final size = resolveWithFallback(
        style?.minimumSize,
        defaultStyle?.minimumSize,
      );
      return size?.toString() ?? 'null';
    }(),
    'fixedSize': () {
      final size = resolveWithFallback(
        style?.fixedSize,
        defaultStyle?.fixedSize,
      );
      return size?.toString() ?? 'null';
    }(),
    'maximumSize': () {
      final size = resolveWithFallback(
        style?.maximumSize,
        defaultStyle?.maximumSize,
      );
      return size?.toString() ?? 'null';
    }(),
    'iconSize': () {
      final size = resolveWithFallback(style?.iconSize, defaultStyle?.iconSize);
      return size?.toString() ?? 'null';
    }(),
    'side': () {
      final side = resolveWithFallback(style?.side, defaultStyle?.side);
      return side != null ? _getBorderSideDetails(side) : {};
    }(),
    'shape': () {
      final shape = resolveWithFallback(style?.shape, defaultStyle?.shape);
      return shape != null ? _getShapeDetails(shape) : {};
    }(),
    'textStyle': () {
      final textStyle = resolveWithFallback(
        style?.textStyle,
        defaultStyle?.textStyle,
      );
      return textStyle != null
          ? getTextStyle(textStyle, context)
          : getTextStyle(null, context);
    }(),
    'mouseCursor': () {
      final cursor = resolveWithFallback(
        style?.mouseCursor,
        defaultStyle?.mouseCursor,
      );
      return cursor?.toString() ?? 'null';
    }(),
    'visualDensity': style?.visualDensity?.toString() ??
        defaultStyle?.visualDensity?.toString() ??
        'null',
    'tapTargetSize': style?.tapTargetSize?.toString() ??
        defaultStyle?.tapTargetSize?.toString() ??
        'null',
    'animationDuration': style?.animationDuration?.toString() ??
        defaultStyle?.animationDuration?.toString() ??
        'null',
    'enableFeedback': style?.enableFeedback?.toString() ??
        defaultStyle?.enableFeedback?.toString() ??
        'null',
    'alignment': style?.alignment?.toString() ??
        defaultStyle?.alignment?.toString() ??
        'null',
    'splashFactory': style?.splashFactory?.toString() ??
        defaultStyle?.splashFactory?.toString() ??
        'null',
  };
}

String colorToHex(Color color) {
  var alphaColor = (color.alpha).toRadixString(16).padLeft(2, '0').toUpperCase();
  var redColor = (color.red).toRadixString(16).padLeft(2, '0').toUpperCase();
  var greenColor = (color.green).toRadixString(16).padLeft(2, '0').toUpperCase();
  var blueColor = (color.blue).toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#$alphaColor$redColor$greenColor$blueColor';
}

Map<String, dynamic> _getBorderDetails(Border? border) {
  if (border == null) return {};
  return {
    'type': 'Border',
    'top': _getBorderSideDetails(border.top),
    'right': _getBorderSideDetails(border.right),
    'bottom': _getBorderSideDetails(border.bottom),
    'left': _getBorderSideDetails(border.left),
  };
}

Map<String, dynamic> _getBorderSideDetails(BorderSide borderSide) {
  return {
    'color': borderSide.color != Colors.transparent
        ? colorToHex(borderSide.color)
        : 'transparent',
    'width': borderSide.width.toString(),
    'style': borderSide.style.toString(),
    'strokeAlign': borderSide.strokeAlign.toString(),
  };
}

Map<String, dynamic> _getShapeDetails(OutlinedBorder shape) {
  Map<String, dynamic> details = {'type': shape.runtimeType.toString()};
  if (shape is RoundedRectangleBorder) {
    details.addAll({
      'borderRadius': _getBorderRadiusDetails(shape.borderRadius),
      'side': _getBorderSideDetails(shape.side),
    });
  } else if (shape is CircleBorder) {
    details.addAll({'side': _getBorderSideDetails(shape.side)});
  } else if (shape is StadiumBorder) {
    details.addAll({'side': _getBorderSideDetails(shape.side)});
  } else if (shape is BeveledRectangleBorder) {
    details.addAll({
      'borderRadius': _getBorderRadiusDetails(shape.borderRadius),
      'side': _getBorderSideDetails(shape.side),
    });
  } else if (shape is ContinuousRectangleBorder) {
    details.addAll({
      'borderRadius': _getBorderRadiusDetails(shape.borderRadius),
      'side': _getBorderSideDetails(shape.side),
    });
  } else {
    details['description'] = shape.toString();
  }
  return details;
}

Map<String, dynamic> _getBorderRadiusDetails(
  BorderRadiusGeometry? borderRadius,
) {
  if (borderRadius == null) return {};
  Map<String, dynamic> details = {'type': borderRadius.runtimeType.toString()};
  if (borderRadius is BorderRadius) {
    details.addAll({
      'topLeft': _getRadiusDetails(borderRadius.topLeft),
      'topRight': _getRadiusDetails(borderRadius.topRight),
      'bottomLeft': _getRadiusDetails(borderRadius.bottomLeft),
      'bottomRight': _getRadiusDetails(borderRadius.bottomRight),
    });
  } else if (borderRadius is BorderRadiusDirectional) {
    details.addAll({
      'topStart': _getRadiusDetails(borderRadius.topStart),
      'topEnd': _getRadiusDetails(borderRadius.topEnd),
      'bottomStart': _getRadiusDetails(borderRadius.bottomStart),
      'bottomEnd': _getRadiusDetails(borderRadius.bottomEnd),
    });
  }
  return details;
}

Map<String, dynamic> _getRadiusDetails(Radius radius) {
  return {'x': radius.x.toString(), 'y': radius.y.toString()};
}

Map<String, dynamic> _getBoxShadowDetails(List<BoxShadow>? boxShadows) {
  if (boxShadows == null || boxShadows.isEmpty) {
    return {};
  }
  return {
    'count': boxShadows.length,
    'shadows': boxShadows
        .map(
          (shadow) => {
            'color': colorToHex(shadow.color),
            'offset': 'dx: ${shadow.offset.dx}, dy: ${shadow.offset.dy}',
            'blurRadius': shadow.blurRadius.toString(),
            'spreadRadius': shadow.spreadRadius.toString(),
            'blurStyle': shadow.blurStyle.toString(),
          },
        )
        .toList(),
  };
}

Map<String, dynamic> _getGradientDetails(Gradient? gradient) {
  if (gradient == null) return {};
  Map<String, dynamic> details = {'type': gradient.runtimeType.toString()};
  if (gradient is LinearGradient) {
    details['begin'] = gradient.begin.toString();
    details['end'] = gradient.end.toString();
    details['colors'] = gradient.colors
        .map((color) => colorToHex(color))
        .toList();
    details['stops'] = gradient.stops?.toString() ?? 'null';
    details['tileMode'] = gradient.tileMode.toString();
  } else if (gradient is RadialGradient) {
    details['center'] = gradient.center.toString();
    details['radius'] = gradient.radius.toString();
    details['colors'] = gradient.colors
        .map((color) => colorToHex(color))
        .toList();
    details['stops'] = gradient.stops?.toString() ?? 'null';
    details['tileMode'] = gradient.tileMode.toString();
  } else if (gradient is SweepGradient) {
    details['center'] = gradient.center.toString();
    details['startAngle'] = gradient.startAngle.toString();
    details['endAngle'] = gradient.endAngle.toString();
    details['colors'] = gradient.colors
        .map((color) => colorToHex(color))
        .toList();
    details['stops'] = gradient.stops?.toString() ?? 'null';
    details['tileMode'] = gradient.tileMode.toString();
  }
  return details;
}

Map<String, dynamic> _getDecorationImageDetails(DecorationImage? image) {
  if (image == null) return {};
  return {
    'fit': image.fit?.toString() ?? 'null',
    'alignment': image.alignment.toString(),
    'repeat': image.repeat.toString(),
    'matchTextDirection': image.matchTextDirection.toString(),
    'scale': image.scale.toString(),
    'opacity': image.opacity.toString(),
    'filterQuality': image.filterQuality.toString(),
    'invertColors': image.invertColors.toString(),
    'isAntiAlias': image.isAntiAlias.toString(),
  };
}

Map<String, dynamic> _extractTextSpanDetails(
  InlineSpan inlineSpan,
  BuildContext context, [
  TextStyle? parentStyle,
]) {
  Map<String, dynamic> spanDetails = {};
  if (inlineSpan is TextSpan) {
    final textSpan = inlineSpan;
    spanDetails['text'] = textSpan.text ?? 'null';
    spanDetails['type'] = 'TextSpan';
    TextStyle? effectiveStyle;
    if (textSpan.style != null) {
      if (parentStyle != null) {
        effectiveStyle = parentStyle.merge(textSpan.style);
      } else {
        effectiveStyle = textSpan.style;
      }
    } else {
      effectiveStyle = parentStyle;
    }
    spanDetails['style'] = getTextStyle(effectiveStyle, context);
    if (textSpan.children != null && textSpan.children!.isNotEmpty) {
      spanDetails['hasChildren'] = 'true';
      spanDetails['childrenCount'] = textSpan.children!.length.toString();
      List<Map<String, dynamic>> childrenDetails = [];
      for (final child in textSpan.children!) {
        childrenDetails.add(
          _extractTextSpanDetails(child, context, effectiveStyle),
        );
      }
      spanDetails['children'] = childrenDetails;
    } else {
      spanDetails['hasChildren'] = 'false';
      spanDetails['childrenCount'] = '0';
      spanDetails['children'] = [];
    }
  } else {
    spanDetails['type'] = inlineSpan.runtimeType.toString();
    TextStyle? effectiveStyle;
    if (inlineSpan.style != null) {
      if (parentStyle != null) {
        effectiveStyle = parentStyle.merge(inlineSpan.style);
      } else {
        effectiveStyle = inlineSpan.style;
      }
    } else {
      effectiveStyle = parentStyle;
    }
    spanDetails['style'] = getTextStyle(effectiveStyle, context);
    spanDetails['hasChildren'] = 'false';
    spanDetails['childrenCount'] = '0';
    spanDetails['children'] = [];
    if (inlineSpan is WidgetSpan) {
      final extractedText = _extractTextFromWidget(inlineSpan.child);
      spanDetails['text'] = extractedText;
    } else {
      spanDetails['text'] = 'null';
    }
  }
  return spanDetails;
}

String _extractTextFromWidget(Widget widget) {
  if (widget is Text) {
    return widget.data ?? '';
  } else if (widget is RichText) {
    return (widget.text as TextSpan).toPlainText(includeSemanticsLabels: false);
  } else {
    return widget.runtimeType.toString();
  }
}

void _sendWidgetInformation(Map<String, dynamic> widgetInfo) {
  // Assuming a function to send the data to the web client exists
  // For example:
  // web.window.parent?.postMessage(jsonEncode(widgetInfo), '*');
}

// Dummy constant to prevent compile errors.
const kRadialReactionRadius = 18.0;

// Re-defining the wrapper widget set to fix a possible bug
// The previous definition was inside a class, which might cause issues.
const Set<String> wrapperWidgetTypeNames = {
  'IgnorePointer',
  'Listener',
  'RawGestureDetector',
  'MouseRegion',
  'KeyedSubtree',
  'Stack',
  'Positioned',
};
