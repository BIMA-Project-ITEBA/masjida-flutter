import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Notification',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Clear all',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Recent'),
              Tab(text: 'Earlier'),
              Tab(text: 'Archived'),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
          children: [
            _buildNotificationList(recentNotifications),
            _buildNotificationList(earlierNotifications),
            // Archived list is empty for now
            const Center(child: Text('No archived notifications.')),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, String>> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(notification['avatar']!),
          ),
          title: Text(
            notification['title']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(notification['subtitle']!),
          trailing: Text(
            notification['time']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          onTap: () {},
        );
      },
    );
  }
}

// Data dummy
final List<Map<String, String>> recentNotifications = [
  {
    'avatar': 'https://placehold.co/100x100/EFEFEF/333?text=MA',
    'title': 'Masjid Agung',
    'subtitle': 'Penawara Dawah',
    'time': 'Sun, 12:40pm',
  },
];

final List<Map<String, String>> earlierNotifications = [
  {
    'avatar': 'https://placehold.co/100x100/E4F2E8/333?text=MJ',
    'title': 'Masjid Jami',
    'subtitle': 'Reminder dawah',
    'time': 'Tue, 10:56pm',
  },
];
