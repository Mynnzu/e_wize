import 'package:flutter/material.dart';

class StyledPageScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;

  const StyledPageScaffold({
    Key? key,
    required this.title,
    this.actions,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF42A5F5),
        elevation: 1,
        title: Text(
          title,
          style: TextStyle(
            color: const Color.fromARGB(221, 255, 255, 255),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: actions,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(padding: EdgeInsets.all(16), child: body),
    );
  }
}
