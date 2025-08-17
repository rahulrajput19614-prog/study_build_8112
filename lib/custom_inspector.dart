import 'package:flutter/material.dart';

class CustomInspector {
  /// Inspect TextFormField properties (constructor-based)
  static Map<String, dynamic> inspectTextFormField({
    InputDecoration? decoration,
    bool? obscureText,
    TextInputType? keyboardType,
    int? maxLength,
    bool? enabled,
  }) {
    return {
      'type': 'TextFormField',
      'labelText': decoration?.labelText,
      'hintText': decoration?.hintText,
      'errorText': decoration?.errorText,
      'obscureText': obscureText,
      'keyboardType': keyboardType?.toString(),
      'maxLength': maxLength,
      'enabled': enabled,
    };
  }

  /// Inspect Text widget
  static Map<String, dynamic> inspectText(Text widget) {
    return {
      'type': 'Text',
      'data': widget.data,
      'style': widget.style?.toString(),
      'textAlign': widget.textAlign?.toString(),
      'overflow': widget.overflow?.toString(),
      'maxLines': widget.maxLines,
    };
  }

  /// Inspect Container widget
  static Map<String, dynamic> inspectContainer(Container widget) {
    return {
      'type': 'Container',
      'width': widget.constraints?.maxWidth,
      'height': widget.constraints?.maxHeight,
      'color': _colorToHex(widget.color),
      'padding': widget.padding?.toString(),
      'margin': widget.margin?.toString(),
      'alignment': widget.alignment?.toString(),
      'childType': widget.child?.runtimeType.toString(),
    };
  }

  /// Inspect Padding widget
  static Map<String, dynamic> inspectPadding(Padding widget) {
    return {
      'type': 'Padding',
      'padding': widget.padding.toString(),
      'childType': widget.child.runtimeType.toString(),
    };
  }

  /// Inspect ElevatedButton widget
  static Map<String, dynamic> inspectElevatedButton(ElevatedButton widget) {
    return {
      'type': 'ElevatedButton',
      'onPressed': widget.onPressed != null ? 'defined' : 'null',
      'childType': widget.child.runtimeType.toString(),
    };
  }

  /// Inspect Switch widget
  static Map<String, dynamic> inspectSwitch(Switch widget) {
    return {
      'type': 'Switch',
      'value': widget.value,
      'activeTrackColor': _colorToHex(widget.activeTrackColor),
      'activeThumbColor': _colorToHex(widget.activeThumbColor),
      'inactiveThumbColor': _colorToHex(widget.inactiveThumbColor),
      'inactiveTrackColor': _colorToHex(widget.inactiveTrackColor),
      'materialTapTargetSize': widget.materialTapTargetSize?.toString(),
    };
  }

  /// Inspect Checkbox widget
  static Map<String, dynamic> inspectCheckbox(Checkbox widget) {
    return {
      'type': 'Checkbox',
      'value': widget.value,
      'checkColor': _colorToHex(widget.checkColor),
      'activeColor': _colorToHex(widget.activeColor),
      'tristate': widget.tristate,
    };
  }

  /// Inspect Slider widget
  static Map<String, dynamic> inspectSlider(Slider widget) {
    return {
      'type': 'Slider',
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'divisions': widget.divisions,
      'label': widget.label,
      'activeTrackColor': _colorToHex(widget.activeColor), // ✅ Updated
      'inactiveColor': _colorToHex(widget.inactiveColor),
    };
  }

  /// Inspect DropdownButton widget
  static Map<String, dynamic> inspectDropdownButton(DropdownButton widget) {
    return {
      'type': 'DropdownButton',
      'value': widget.value?.toString(),
      'itemsCount': widget.items?.length ?? 0,
      'hint': widget.hint?.runtimeType.toString(),
      'isExpanded': widget.isExpanded,
      'underline': widget.underline?.runtimeType.toString(),
    };
  }

  /// Inspect Flex widget (Row/Column)
  static Map<String, dynamic> inspectFlex(Flex widget) {
    return {
      'type': 'Flex',
      'direction': widget.direction.toString(),
      'mainAxisAlignment': widget.mainAxisAlignment.toString(),
      'crossAxisAlignment': widget.crossAxisAlignment.toString(),
      'textDirection': widget.textDirection?.toString(),
      'verticalDirection': widget.verticalDirection.toString(),
    };
  }

  /// Helper to convert Color to hex string
  static String? _colorToHex(Color? color) {
    if (color == null) return null;
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}'; // ✅ Updated
  }
}
