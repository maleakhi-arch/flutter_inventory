import 'package:flutter/material.dart';

class DesktopLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget body;

  const DesktopLayout({
    super.key,
    required this.sidebar,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          Container(
            width: 250,
            color: Colors.blue,
            child: sidebar,
          ),

          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}