import 'package:flutter/material.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Color(0xFF6B0D0D).withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'Layanan Chat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF6B0D0D)),
          ),
          const SizedBox(height: 8),
          const Text('Hubungi admin koperasi melalui fitur ini.', style: TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }
}
