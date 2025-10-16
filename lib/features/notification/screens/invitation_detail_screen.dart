import 'package:flutter/material.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/invitation_model.dart';

class InvitationDetailScreen extends StatefulWidget {
  final Invitation invitation;
  const InvitationDetailScreen({super.key, required this.invitation});

  @override
  State<InvitationDetailScreen> createState() => _InvitationDetailScreenState();
}

class _InvitationDetailScreenState extends State<InvitationDetailScreen> {
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  void _handleAction(Future<bool> Function(int) action) async {
    setState(() => _isLoading = true);
    try {
      final success = await action(widget.invitation.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Aksi berhasil!' : 'Aksi gagal.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        // Kembali ke halaman sebelumnya dengan hasil true
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Undangan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.invitation.topic, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            _buildInfoRow(Icons.mosque, 'Masjid', widget.invitation.mosqueName),
            _buildInfoRow(Icons.calendar_today, 'Tanggal', widget.invitation.formattedDate),
            _buildInfoRow(Icons.access_time, 'Waktu', widget.invitation.formattedTime),
            const SizedBox(height: 16),
            const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(widget.invitation.description ?? 'Tidak ada deskripsi.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Tolak'),
                  onPressed: () => _handleAction(apiService.rejectInvitation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Terima'),
                  onPressed: () => _handleAction(apiService.confirmInvitation),
                   style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          );
  }
}
