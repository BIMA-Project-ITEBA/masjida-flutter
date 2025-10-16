import 'package:flutter/material.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/invitation_model.dart';
import 'invitation_detail_screen.dart'; // Halaman baru yang akan kita buat

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<Invitation>> futureInvitations;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  void _loadInvitations() {
    setState(() {
      futureInvitations = apiService.getPendingInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Invitation>>(
        future: futureInvitations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child:
                    Text("Gagal memuat notifikasi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada undangan baru.'));
          } else {
            final invitations = snapshot.data!;
            return ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                final invitation = invitations[index];
                return _buildInvitationCard(invitation);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildInvitationCard(Invitation invitation) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            NetworkImage(apiService.getFullImageUrl(invitation.mosqueImageUrl)),
        child: (invitation.mosqueImageUrl == null) ? const Icon(Icons.mosque) : null,
      ),
      title: Text(
        invitation.mosqueName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Mengundang Anda untuk kajian: "${invitation.topic}"'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => InvitationDetailScreen(invitation: invitation),
          ),
        );
        // Jika detail screen mengembalikan true (ada aksi), muat ulang daftar
        if (result == true) {
          _loadInvitations();
        }
      },
    );
  }
}
