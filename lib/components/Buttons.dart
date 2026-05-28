import 'package:flutter/material.dart';

Widget buildButton(VoidCallback vcb, Icon i, Text t, Color c) {
  return ElevatedButton.icon(
    onPressed: vcb,
    style: ElevatedButton.styleFrom(
      backgroundColor: c,
      iconColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      fixedSize: Size(150, 40),
    ),
    icon: i,
    label: t,
  );
}
// ignore: file_names

class SimpleToggleButton extends StatefulWidget {
  const SimpleToggleButton({super.key});

  @override
  State<SimpleToggleButton> createState() => _SimpleToggleButtonState();
}

class _SimpleToggleButtonState extends State<SimpleToggleButton> {
  bool isToggled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Toggle')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isToggled = !isToggled;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isToggled ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text(isToggled ? 'ON' : 'OFF'),
        ),
      ),
    );
  }
}
class VertIconButton extends StatefulWidget {
  const VertIconButton({
    super.key,
    required this.onPressed,
    this.dIcon = Icons.file_copy_outlined,
    this.text = "0/",
    this.color = Colors.transparent,
  });
  final IconData dIcon;
  final String text;
  final VoidCallback onPressed;
  final Color color;

  @override
  State<StatefulWidget> createState() => _VertIconButton();
}

//Implementation of the shortcut
class _VertIconButton extends State<VertIconButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        alignment: Alignment.center,
        backgroundColor: Colors.green,
        shadowColor: Colors.transparent,
        iconColor: widget.color,
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(widget.dIcon),
          SizedBox(height: 5),
          Text(widget.text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}