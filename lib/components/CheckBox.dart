import "package:flutter/material.dart";

// ignore: non_constant_identifier_names
Widget CheckBox({
  required bool value,
  required ValueChanged<bool?> onChanged,
}) {
  Color getColor(Set<WidgetState> states) {
    return states.contains(WidgetState.selected) ? Colors.green : Colors.white;
  }

  return Checkbox(
    value: value,
    onChanged: onChanged,
    fillColor: WidgetStateProperty.resolveWith(getColor),
    checkColor: Colors.white,
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
