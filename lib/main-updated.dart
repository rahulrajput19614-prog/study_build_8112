import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrackingWidget extends StatefulWidget {
  final Widget child;
  const TrackingWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<TrackingWidget> createState() => _TrackingWidgetState();
}

class _TrackingWidgetState extends State<TrackingWidget> {
  final GlobalKey _childKey = GlobalKey();
  RenderObject? _selectedRenderObject;
  Element? _selectedElement;
  Timer? _debounce;
  Timer? _scrollDebounce;
  String currentPage = 'home';

  final Map<Type, String> knownWidgetTypes = {
    SliverFillRemaining: 'SliverFillRemaining',
    SliverPadding: 'SliverPadding',
    SliverFixedExtentList: 'SliverFixedExtentList',
    SliverFillViewport: 'SliverFillViewport',
    SliverPersistentHeader: 'SliverPersistentHeader',
  };

  String? findNearestKnownWidget(Element? element) {
    if (element == null) return null;
    Widget widget = element.widget;
    return knownWidgetTypes[widget.runtimeType] ?? _getCustomWidgetType(widget);
  }

  String? _getCustomWidgetType(Widget widget) => null;

  void trackInteraction(String eventType, PointerEvent? event) {
    try {
      if (eventType == 'mouseleave') {
        Future.delayed(const Duration(milliseconds: 300), () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
        });
      }

      RenderBox? renderBox = _selectedRenderObject is RenderBox
          ? _selectedRenderObject as RenderBox
          : null;

      final offset = renderBox?.localToGlobal(Offset.zero);
      final size = renderBox?.size;
      final mousePosition = event?.position;
      final scrollPosition = _getScrollPosition(_selectedRenderObject);

      final interactionData = {
        'eventType': eventType,
        'timestamp': DateTime.now().toIso8601String(),
        'element': {
          'tag': findNearestKnownWidget(_selectedElement),
          'id': _selectedElement?.widget.key?.toString() ??
              widget.child.key?.toString(),
          'position': offset != null
              ? {
                  'x': offset.dx.round(),
                  'y': offset.dy.round(),
                  'width': size?.width.round(),
                  'height': size?.height.round(),
                }
              : null,
          'viewport': {
            'width': MediaQuery.of(context).size.width.round(),
            'height': MediaQuery.of(context).size.height.round(),
          },
          'scroll': {
            'x': scrollPosition.dx.round(),
            'y': scrollPosition.dy.round(),
          },
          'mouse': mousePosition != null
              ? {
                  'viewport': {
                    'x': mousePosition.dx.round(),
                    'y': mousePosition.dy.round(),
                  },
                  'page': {
                    'x': (mousePosition.dx + scrollPosition.dx).round(),
                    'y': (mousePosition.dy + scrollPosition.dy).round(),
                  },
                  'element': offset != null
                      ? {
                          'x': (mousePosition.dx - offset.dx).round(),
                          'y': (mousePosition.dy - offset.dy).round(),
                        }
                      : null,
                }
              : null,
        },
        'page': '/#$currentPage',
      };

      // Web-specific code removed as it was causing errors
    } catch (error) {
      debugPrint('Error tracking interaction: $error');
    }
  }

  Offset _getScrollPosition(RenderObject? renderObject) {
    if (renderObject == null) return Offset.zero;
    final element = _findElementForRenderObject(renderObject);
    if (element == null) return Offset.zero;
    final scrollableState = Scrollable.maybeOf(element);
    if (scrollableState != null) {
      final position = scrollableState.position;
      return Offset(position.pixels, position.pixels);
    }
    return Offset.zero;
  }

  void _debouncedMouseMove(PointerHoverEvent event) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 10), () {
      _onHover(event);
      trackInteraction('mousemove', event);
    });
  }

  void _onHover(PointerHoverEvent event) {
    final RenderObject? userRender =
        _childKey.currentContext?.findRenderObject();
    if (userRender == null) return;
    final RenderObject? target =
        _findRenderObjectAtPosition(event.position, userRender);
    if (target != null && target != userRender) {
      if (_selectedRenderObject != target) {
        final Element? element = _findElementForRenderObject(target);
        setState(() {
          _selectedRenderObject = target;
          _selectedElement = element;
        });
      }
    } else if (_selectedRenderObject != null) {
      setState(() {
        _selectedRenderObject = null;
        _selectedElement = null;
      });
    }
  }

  RenderObject? _findRenderObjectAtPosition(
      Offset position, RenderObject root) {
    final List<RenderObject> hits = <RenderObject>[];
    _hitTestHelper(hits, position, root, root.getTransformTo(null));
    if (hits.isEmpty) return null;
    hits.sort((a, b) {
      final sizeA = a.semanticBounds.size;
      final sizeB = b.semanticBounds.size;
      return (sizeA.width * sizeA.height).compareTo(sizeB.width * sizeB.height);
    });
    return hits.first;
  }

  bool _hitTestHelper(List<RenderObject> hits, Offset position,
      RenderObject object, Matrix4 transform) {
    bool hit = false;
    final Matrix4? inverse = Matrix4.tryInvert(transform);
    if (inverse == null) return false;
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);
    final List<DiagnosticsNode> children = object.debugDescribeChildren();
    for (int i = children.length - 1; i >= 0; i--) {
      final DiagnosticsNode diagnostics = children[i];
      if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
          diagnostics.value is! RenderObject) continue;
      final RenderObject child = diagnostics.value! as RenderObject;
      final Rect? paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition)) continue;
      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(hits, position, child, childTransform)) hit = true;
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

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: _debouncedMouseMove,
      onPointerDown: (event) => trackInteraction('click', event),
      onPointerMove: (event) => trackInteraction('touchmove', event),
      onPointerUp: (event) => trackInteraction('touchend', event),
      child: MouseRegion(
        onEnter: (event) => trackInteraction('mouseenter', event),
        onExit: (event) => trackInteraction('mouseleave', event),
        child: GestureDetector(
          onDoubleTap: () => trackInteraction('dblclick', null),
          onTap: () => trackInteraction('click', null),
          onPanStart: (_) => trackInteraction('touchstart', null),
          onPanUpdate: (_) => trackInteraction('touchmove', null),
          onPanEnd: (_) => trackInteraction('touchend', null),
          child: FocusScope(
            key: _childKey,
            onKeyEvent: (_, event) {
              if (event is RawKeyDownEvent) {
                trackInteraction('keydown', null);
              }
              return KeyEventResult.ignored;
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
