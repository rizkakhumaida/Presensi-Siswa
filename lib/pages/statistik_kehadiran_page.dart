import 'package:flutter/material.dart';

class StatistikKehadiranPage extends StatelessWidget {
  const StatistikKehadiranPage({super.key});

  // Dummy (nanti ganti dari Supabase/provider) - harus sama seperti profil
  final int hadir = 20;
  final int telat = 3;
  final int izin = 2;
  final int alpha = 1;

  final double rataJamMasuk = 7.05;
  final int streakHadir = 5;

  static const Color _navy = Color(0xFF1E3A8A);
  static const Color _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    // ✅ Sama seperti profil: total rekap = hadir+telat+izin+alpha
    final int totalRekap = hadir + telat + izin + alpha;

    // ✅ Sama seperti profil: persentase hadir = hadir / totalRekap
    final double persentaseHadir =
        totalRekap == 0 ? 0.0 : (hadir / totalRekap);

    // ✅ Sama seperti profil: teks persen dibulatkan (profil menampilkan 77% bukan 76.9)
    final int persenBulatan = (persentaseHadir * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Statistik Kehadiran"),
        elevation: 0,
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: "Kembali",
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final isMobile = w < 600;
          final isTablet = w >= 600 && w < 1024;

          final pad = isMobile ? 14.0 : 18.0;
          final gridCount = isMobile ? 2 : (isTablet ? 3 : 4);
          final gridAspect = isMobile ? 1.45 : 1.75;

          return SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 980,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======================
                    // Ringkasan Kehadiran (SAMA SEPERTI PROFIL)
                    // ======================
                    const Text(
                      "Ringkasan Kehadiran",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // baris atas: Total Rekap + persen
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: const [
                                    Icon(Icons.analytics_rounded,
                                        size: 18, color: Colors.black87),
                                    SizedBox(width: 8),
                                    Text(
                                      "Total Rekap:",
                                      style: TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "$persenBulatan% Hadir",
                                style: const TextStyle(
                                  color: _green,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Total angka (biar sama seperti profil yang menampilkan 26)
                          Text(
                            "$totalRekap",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: persentaseHadir.clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation(_green),
                            ),
                          ),
                          const SizedBox(height: 10),

                          const Text(
                            "Persentase hadir dihitung dari total rekap (hadir, telat, izin, alpha).",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ======================
                    // Rekap Kehadiran (SAMA SEPERTI PROFIL)
                    // ======================
                    const Text(
                      "Rekap Kehadiran",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: gridCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: gridAspect,
                      children: [
                        _StatTile(
                          label: "Hadir",
                          value: hadir,
                          icon: Icons.check_circle_rounded,
                          color: Colors.green,
                          isMobile: isMobile,
                        ),
                        _StatTile(
                          label: "Telat",
                          value: telat,
                          icon: Icons.access_time_rounded,
                          color: Colors.orange,
                          isMobile: isMobile,
                        ),
                        _StatTile(
                          label: "Izin",
                          value: izin,
                          icon: Icons.assignment_turned_in_rounded,
                          color: Colors.blue,
                          isMobile: isMobile,
                        ),
                        _StatTile(
                          label: "Alpha",
                          value: alpha,
                          icon: Icons.cancel_rounded,
                          color: Colors.red,
                          isMobile: isMobile,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ======================
                    // Insight Kehadiran
                    // ======================
                    const Text(
                      "Insight Kehadiran",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    _InfoTile(
                      icon: Icons.schedule_rounded,
                      title: "Rata-rata Jam Masuk",
                      value: rataJamMasuk.toStringAsFixed(2),
                      suffix: "WIB",
                      color: Colors.indigo,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 10),
                    _InfoTile(
                      icon: Icons.local_fire_department_rounded,
                      title: "Streak Hadir",
                      value: streakHadir.toString(),
                      suffix: "hari",
                      color: Colors.deepOrange,
                      isMobile: isMobile,
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* =========================
   COMPONENTS
========================= */

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool isMobile;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isMobile ? 18.0 : 20.0;
    final radius = isMobile ? 16.0 : 18.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // anti overflow
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color, size: iconSize),
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Text(
            "$value",
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black54, fontSize: isMobile ? 12 : 13),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String suffix;
  final Color color;
  final bool isMobile;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.suffix,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 20 : 22,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color, size: isMobile ? 20 : 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black54, fontSize: isMobile ? 12 : 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "$value $suffix",
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
