import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget MyStyledButton(
    {EdgeInsetsGeometry? outerPadding,
    EdgeInsetsGeometry innerPadding =
        const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
    Color color = Colors.blue,
    void Function()? callback,
    Widget? child}) {
  return Padding(
    padding: outerPadding!,
    child: Material(
      elevation: 5,
      color: color,
      borderRadius: BorderRadius.circular(32),
      child: MaterialButton(
        onPressed: callback,
        padding: innerPadding,
        child: Center(
          child: child,
        ),
      ),
    ),
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

Widget reportButton({
  tapCallback,
  color: Colors.blue,
  text: 'Текст',
  trailing: false,
  trailingIcon: Icons.calendar_today,
  trailingOnPressed,
}) =>
    Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(32),
            child: InkWell(
              onTap: tapCallback,
              borderRadius: BorderRadius.circular(32),
              child: Container(
                padding: EdgeInsets.all(16),
                constraints: BoxConstraints(minWidth: 0, maxWidth: 400),
                child: ListTile(
                  title: Center(
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                  trailing: trailing
                      ? IconButton(
                          icon: Icon(
                            trailingIcon,
                            size: 40,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: trailingOnPressed,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
