import 'package:flutter/material.dart';

class JadwalPelajaranPage extends StatelessWidget {
  const JadwalPelajaranPage({super.key});

  final List<Map<String, String>> jadwalHariIni = const [
    {"jam": "07:00 - 08:30", "mapel": "Matematika"},
    {"jam": "08:30 - 10:00", "mapel": "Bahasa Indonesia"},
    {"jam": "10:15 - 11:45", "mapel": "IPA"},
  ];

  final List<Map<String, String>> jadwalMingguan = const [
    {"hari": "Senin", "mapel": "Matematika, IPA"},
    {"hari": "Selasa", "mapel": "Bahasa Indonesia, IPS"},
    {"hari": "Rabu", "mapel": "Bahasa Inggris, Seni"},
    {"hari": "Kamis", "mapel": "Penjas, PKN"},
    {"hari": "Jumat", "mapel": "Agama, TIK"},
  ];

  static const Color _navy = Color(0xFF1E3A8A);

  IconData _iconForMapel(String mapel) {
    final m = mapel.toLowerCase();
    if (m.contains("mat")) return Icons.calculate_rounded;
    if (m.contains("indonesia")) return Icons.menu_book_rounded;
    if (m.contains("ipa")) return Icons.science_rounded;
    if (m.contains("ips")) return Icons.public_rounded;
    if (m.contains("inggris")) return Icons.language_rounded;
    if (m.contains("seni")) return Icons.palette_rounded;
    if (m.contains("penjas")) return Icons.sports_soccer_rounded;
    if (m.contains("pkn")) return Icons.gavel_rounded;
    if (m.contains("agama")) return Icons.mosque_rounded;
    if (m.contains("tik")) return Icons.computer_rounded;
    return Icons.school_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isWide = width >= 980;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text("Jadwal Pelajaran"),
        leading: IconButton(
          tooltip: "Kembali",
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        child: Center(
          child: ConstrainedBox(
            // FIX: Jangan paksa maxWidth kecil saat mobile
            constraints: BoxConstraints(
              maxWidth: isWide ? 1100 : (isMobile ? double.infinity : 720),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopSummary(
                  totalHariIni: jadwalHariIni.length,
                  totalMingguan: jadwalMingguan.length,
                ),
                const SizedBox(height: 14),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _todayCard()),
                      const SizedBox(width: 14),
                      SizedBox(width: 420, child: _weeklyCard()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _todayCard(),
                      const SizedBox(height: 14),
                      _weeklyCard(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _todayCard() {
    return _SectionCard(
      title: "Jadwal Hari Ini",
      subtitle: "Urutan pelajaran berdasarkan jam.",
      icon: Icons.today_rounded,
      child: Column(
        children: List.generate(jadwalHariIni.length, (i) {
          final item = jadwalHariIni[i];
          final isLast = i == jadwalHariIni.length - 1;

          return _TimelineTile(
            time: item["jam"] ?? "-",
            title: item["mapel"] ?? "-",
            icon: _iconForMapel(item["mapel"] ?? ""),
            isLast: isLast,
          );
        }),
      ),
    );
  }

  Widget _weeklyCard() {
    return _SectionCard(
      title: "Jadwal Mingguan",
      subtitle: "Ringkasan mapel per hari.",
      icon: Icons.calendar_month_rounded,
      child: Column(
        children: jadwalMingguan.map((j) {
          final hari = j["hari"] ?? "-";
          final mapel = (j["mapel"] ?? "-")
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _navy.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.event_note_rounded,
                          color: _navy, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hari,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: mapel.map((m) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_iconForMapel(m), size: 16, color: _navy),
                          const SizedBox(width: 6),
                          Text(
                            m,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/* =========================
   COMPONENTS
========================= */

class _TopSummary extends StatelessWidget {
  final int totalHariIni;
  final int totalMingguan;

  const _TopSummary({
    required this.totalHariIni,
    required this.totalMingguan,
  });

  static const Color _navy = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isMobile = c.maxWidth < 520;

        final headerRow = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _navy.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.schedule_rounded, color: _navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Jadwal Anda",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Lihat jadwal hari ini dan ringkasan jadwal mingguan.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final pills = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Pill(label: "Hari ini", value: "$totalHariIni sesi"),
            _Pill(label: "Mingguan", value: "$totalMingguan hari"),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerRow,
                    const SizedBox(height: 12),
                    pills, // pindah ke bawah agar tidak “mencekik” teks
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: headerRow),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: pills,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;

  const _Pill({required this.label, required this.value});

  static const Color _navy = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: _navy,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  static const Color _navy = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _navy.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _navy),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final String time;
  final String title;
  final IconData icon;
  final bool isLast;

  const _TimelineTile({
    required this.time,
    required this.title,
    required this.icon,
    required this.isLast,
  });

  static const Color _navy = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _navy.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _navy.withOpacity(0.18)),
                ),
                child: Icon(icon, color: _navy, size: 18),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 26,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: _navy.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
