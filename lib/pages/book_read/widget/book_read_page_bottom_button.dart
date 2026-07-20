import 'package:flutter/material.dart';

class BookReadPageBottomButton extends StatelessWidget {
  const BookReadPageBottomButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.text,
    this.color,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // 图标在上方下方是文字的按钮
    return TextButton(
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
          ),
          Text(
            text,
            style: color != null ? TextStyle(color: color) : null,
          ),
        ],
      ),
    );
  }
}
