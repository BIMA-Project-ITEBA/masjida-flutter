import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk daftar chat
    final List<Map<String, dynamic>> chatList = [
      {
        "name": "Ust. haidil",
        "message": "Hi, Pak John! 👋",
        "time": "09:46",
        "avatar": "https://placehold.co/100x100/EFEFEF/333?text=H",
        "isTyping": false,
        "status": "read",
        "isOnline": false,
      },
      {
        "name": "Adom Shafi",
        "message": "Typing...",
        "time": "08:42",
        "avatar": "https://placehold.co/100x100/DDEEFF/333?text=AS",
        "isTyping": true,
        "status": "read",
        "isOnline": true,
      },
      {
        "name": "Alim Masjid Jami",
        "message": "You: Makasi! 😉",
        "time": "Yesterday",
        "avatar": "https://placehold.co/100x100/FFDDCB/333?text=AM",
        "isTyping": false,
        "status": "sent",
        "isOnline": true,
      }
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 20),
            // Daftar Chat
            Expanded(
              child: ListView.builder(
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  final chat = chatList[index];
                  return _buildChatItem(
                    name: chat['name'],
                    message: chat['message'],
                    time: chat['time'],
                    avatarUrl: chat['avatar'],
                    isTyping: chat['isTyping'],
                    status: chat['status'],
                    isOnline: chat['isOnline'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for chats & messages',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildChatItem({
    required String name,
    required String message,
    required String time,
    required String avatarUrl,
    required bool isTyping,
    required String status,
    required bool isOnline,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          // Avatar dengan status online
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 14,
                    width: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Nama dan Pesan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isTyping ? Colors.blue : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Waktu dan status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Icon(
                status == 'read' ? Icons.done_all : Icons.done,
                color: status == 'read' ? Colors.blue : Colors.grey,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
