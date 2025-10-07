import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Kita butuh ini untuk format tanggal

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // State untuk melacak tanggal yang difokuskan (bulan) dan yang dipilih
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk jadwal
    final List<Map<String, String>> scheduleList = [
      {
        "time": "12:00, 22 October 2025",
        "dai": "Ust. Maulana",
        "mosque": "Masjid Agung",
        "image": "https://placehold.co/100x100/EFEFEF/333?text=MA"
      },
      {
        "time": "15:00, 22 October 2025",
        "dai": "Ust. Somad",
        "mosque": "Masjid Agung",
        "image": "https://placehold.co/100x100/EFEFEF/333?text=US"
      },
      {
        "time": "15:00, 22 October 2025",
        "dai": "Ust. Zakir Naik",
        "mosque": "Masjid Agung",
        "image": "https://placehold.co/100x100/EFEFEF/333?text=UZN"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Schedule',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kalender Horizontal
              _buildHorizontalCalendar(),
              const SizedBox(height: 30),
              // Header Jadwal Saya
              _buildSectionHeader("My Schedule", "View all"),
              const SizedBox(height: 20),
              // Daftar Jadwal
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scheduleList.length,
                itemBuilder: (context, index) {
                  final schedule = scheduleList[index];
                  return _buildScheduleCard(
                    time: schedule['time']!,
                    dai: schedule['dai']!,
                    mosque: schedule['mosque']!,
                    imageUrl: schedule['image']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === KALENDER DIPERBARUI MENJADI DINAMIS ===
  Widget _buildHorizontalCalendar() {
    // Fungsi untuk mendapatkan jumlah hari dalam sebulan
    int daysInMonth(DateTime date) {
      return DateTime(date.year, date.month + 1, 0).day;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_focusedDay), // Bulan dan tahun dinamis
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Pindah ke bulan sebelumnya
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_left)
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Pindah ke bulan berikutnya
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_right)
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: daysInMonth(_focusedDay), // Jumlah hari dinamis
            itemBuilder: (context, index) {
              final date = DateTime(_focusedDay.year, _focusedDay.month, index + 1);
              final dayOfWeek = DateFormat('E').format(date);
              final isSelected = date.day == _selectedDay.day && date.month == _selectedDay.month && date.year == _selectedDay.year;
              
              return _buildDateItem(
                day: dayOfWeek.substring(0, 1), // Ambil huruf pertama dari hari
                dateNumber: date.day,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedDay = date;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem({
    required String day,
    required int dateNumber,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
            const SizedBox(height: 8),
            Text(
              dateNumber.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          actionText,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard({
    required String time,
    required String dai,
    required String mosque,
    required String imageUrl,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.mosque, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dai,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        mosque,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

