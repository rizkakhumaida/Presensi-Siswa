import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Kehadiran {
  String tanggal; // dd-MM-yyyy
  String jamMasuk;
  String jamPulang;
  String status; // "Tepat Waktu" | "Terlambat/Telat" | "Izin" | "Alpha"

  Kehadiran({
    required this.tanggal,
    required this.jamMasuk,
    required this.jamPulang,
    required this.status,
  });
}

class RiwayatKehadiranPage extends StatefulWidget {
  @override
  State<RiwayatKehadiranPage> createState() => _RiwayatKehadiranPageState();
}

class _RiwayatKehadiranPageState extends State<RiwayatKehadiranPage> {
  List<Kehadiran> riwayat = [
    Kehadiran(tanggal: "27-11-2025", jamMasuk: "06:35", jamPulang: "15:45", status: "Tepat Waktu"),
    Kehadiran(tanggal: "26-11-2025", jamMasuk: "07:10", jamPulang: "15:50", status: "Terlambat/Telat"),
    Kehadiran(tanggal: "25-11-2025", jamMasuk: "-", jamPulang: "-", status: "Izin"),
    Kehadiran(tanggal: "24-11-2025", jamMasuk: "-", jamPulang: "-", status: "Alpha"),
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime _parseDate(String ddMMyyyy) {
    final p = ddMMyyyy.split("-");
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.day)}-${two(d.month)}-${d.year}";
  }

  Map<DateTime, List<Kehadiran>> get events {
    final map = <DateTime, List<Kehadiran>>{};
    for (final e in riwayat) {
      final d = _parseDate(e.tanggal);
      final key = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  List<Kehadiran> _eventsOfDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Tepat Waktu":
        return Colors.green;
      case "Terlambat/Telat":
        return Colors.red;
      case "Izin":
        return Colors.blue;
      default:
        return Colors.grey; // Alpha
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Tepat Waktu":
        return Icons.check_circle;
      case "Terlambat/Telat":
        return Icons.error;
      case "Izin":
        return Icons.info;
      default:
        return Icons.cancel;
    }
  }

  String _jamAturan() => "Masuk 06:00–07:00 • Pulang 15:30–16:00";

  Map<String, int> _summaryCount() {
    int tepat = 0, telat = 0, izin = 0, alpha = 0;
    for (final r in riwayat) {
      if (r.status == "Tepat Waktu") tepat++;
      else if (r.status == "Terlambat/Telat") telat++;
      else if (r.status == "Izin") izin++;
      else alpha++;
    }
    return {"Tepat": tepat, "Telat": telat, "Izin": izin, "Alpha": alpha};
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;
    final sum = _summaryCount();

    final selected = _selectedDay ?? DateTime.now();
    final selectedList = _eventsOfDay(selected);
    final selectedData = selectedList.isNotEmpty ? selectedList.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER BANNER + BACK (PAS DI DALAM BANNER)
                  _headerBanner(
                    sum: sum,
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 14),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _calendarCard()),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 360,
                          child: Column(
                            children: [
                              _detailCard(selected, selectedData),
                              const SizedBox(height: 14),
                              _legendCard(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _calendarCard(),
                        const SizedBox(height: 14),
                        _detailCard(selected, selectedData),
                        const SizedBox(height: 14),
                        _legendCard(),
                      ],
                    ),

                  const SizedBox(height: 14),
                  _listTitleRow(selected),
                  const SizedBox(height: 10),
                  _historyList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== UI PARTS =====================

  Widget _headerBanner({
    required Map<String, int> sum,
    required VoidCallback onBack,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW TOP: BACK + TITLE
          Row(
            children: [
              _BackPill(onTap: onBack),
              const SizedBox(width: 12),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.history, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Riwayat Kehadiran",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Aturan: ${_jamAturan()}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _miniPill("Tepat", sum["Tepat"] ?? 0, Colors.green),
              _miniPill("Telat", sum["Telat"] ?? 0, Colors.red),
              _miniPill("Izin", sum["Izin"] ?? 0, Colors.blue),
              _miniPill("Alpha", sum["Alpha"] ?? 0, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPill(String label, int value, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            "$label: $value",
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _calendarCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF1E3A8A),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          todayTextStyle: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, ev) {
            final list = _eventsOfDay(day);
            if (list.isEmpty) return null;
            final c = _statusColor(list.first.status);
            return Positioned(
              bottom: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detailCard(DateTime selected, Kehadiran? data) {
    final tgl = _fmtDate(selected);

    if (data == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text("Detail Kehadiran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Text(tgl, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Tidak ada data kehadiran pada tanggal ini.",
              style: TextStyle(color: Colors.black54, height: 1.3),
            ),
          ],
        ),
      );
    }

    final c = _statusColor(data.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_statusIcon(data.status), color: c),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Detail Kehadiran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(tgl, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(data.status, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _timeTile("Masuk", data.jamMasuk, Icons.login, const Color(0xFF16A34A))),
              const SizedBox(width: 10),
              Expanded(child: _timeTile("Pulang", data.jamPulang, Icons.logout, const Color(0xFF7C3AED))),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Aturan: Masuk 06:00–07:00 • Pulang 15:30–16:00",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _timeTile(String label, String value, IconData icon, Color c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendCard() {
    Widget dot(Color c, String t) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Legenda Marker", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              dot(Colors.green, "Tepat Waktu"),
              dot(Colors.red, "Terlambat/Telat"),
              dot(Colors.blue, "Izin"),
              dot(Colors.grey, "Alpha"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listTitleRow(DateTime selected) {
    return Row(
      children: [
        const Expanded(
          child: Text("List Kehadiran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Text(_fmtDate(selected), style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }

  Widget _historyList() {
    return Column(
      children: riwayat.map((data) {
        final c = _statusColor(data.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_statusIcon(data.status), color: c),
            ),
            title: Text(data.tanggal, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Masuk: ${data.jamMasuk}  |  Pulang: ${data.jamPulang}\nStatus: ${data.status}",
                style: const TextStyle(height: 1.35),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                data.status,
                style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            onTap: () {
              setState(() {
                _selectedDay = _parseDate(data.tanggal);
                _focusedDay = _selectedDay!;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}

class _BackPill extends StatefulWidget {
  final VoidCallback onTap;
  const _BackPill({required this.onTap});

  @override
  State<_BackPill> createState() => _BackPillState();
}

class _BackPillState extends State<_BackPill> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _down ? 0.96 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                "Kembali",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
