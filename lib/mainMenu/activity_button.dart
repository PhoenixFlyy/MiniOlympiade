import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActivityButton extends StatelessWidget {
  final String name;
  final String description;
  final Widget iconWidget;
  final VoidCallback onPressed;

  const ActivityButton(
      {super.key, required this.name, required this.iconWidget, required this.description, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade800],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(width: 64, height: 64, child: FittedBox(fit: BoxFit.contain, child: iconWidget)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(description,
                            style: TextStyle(fontSize: 14, color: Colors.grey[350]!),
                            softWrap: true,
                            overflow: TextOverflow.fade)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
