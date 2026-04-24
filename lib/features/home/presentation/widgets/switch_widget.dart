import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xffC23AF5),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xffEEF2F6),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}