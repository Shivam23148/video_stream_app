import 'package:flutter/material.dart';

class SelectionButton extends StatelessWidget {
  SelectionButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.isButtonPressed,
  });
  final onTap;
  final String label;
  bool isButtonPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: MediaQuery.sizeOf(context).height * 0.2,
        width: MediaQuery.sizeOf(context).width * 0.4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: isButtonPressed ? Colors.black : Colors.grey.shade400,
              ),
            ),
            Icon(
              isButtonPressed ? Icons.check_box : Icons.check_box_outline_blank,
              size: 40,
              color: isButtonPressed ? Colors.blue : Colors.blue.shade400,
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isButtonPressed
                ? Colors.grey.shade300
                : Colors.grey.shade100,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isButtonPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: Offset(5, 5),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-6, -6),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
        ),
      ),
    );
  }
}
