import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../provider/attendance_provider.dart';

import 'login_page.dart';
import 'riwayat_kehadiran_page.dart';
import 'pengajuan/pengajuan_izin_page.dart';
import 'statistik_kehadiran_page.dart';
import 'jadwal_pelajaran_page.dart';
import 'pengumuman_page.dart';
import 'profil_page.dart';
import 'presensi_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  // ✅ REVISI: pengumuman mengikuti style card seperti halaman Pengumuman
  final List<Map<String, dynamic>> _announcements = [
    {
      "kategori": "Info Kegiatan",
      "prioritas": "Rendah",
      "judul": "Lomba Olahraga Antar Kelas",
      "isi": "Lomba olahraga antar kelas akan dilaksanakan 5 Januari. Pendaftaran via wali kelas.",
      "tanggal": DateTime(2026, 1, 5),
      "dibaca": false,
    },
    {
      "kategori": "Info Sekolah",
      "prioritas": "Sedang",
      "judul": "Libur Semester",
      "isi": "Libur semester mulai 20 Desember. Pastikan semua tugas sudah dikumpulkan.",
      "tanggal": DateTime(2025, 12, 20),
      "dibaca": true,
    },
    {
      "kategori": "Info Ujian",
      "prioritas": "Tinggi",
      "judul": "UAS Dimulai",
      "isi": "Ujian akhir semester dimulai 10 Desember. Cek jadwal pelajaran di menu Jadwal.",
      "tanggal": DateTime(2025, 12, 10),
      "dibaca": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AttendanceProvider>().loadToday();
    });
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(local.hour)}:${two(local.minute)}";
  }

  void _logout() {
    context.read<AttendanceProvider>().clearLocal();
    context.read<AuthProvider>().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final attendance = context.watch<AttendanceProvider>();

    final email = auth.user?.email ?? "Nama Siswa";
    final kelas = "XI IPA 1";

    final now = DateTime.now();
    final bulan = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    final tanggalRingkas = "${now.day} ${bulan[now.month - 1]}";

    final today = attendance.today;
    final sudahMasuk = today?.checkInAt != null;
    final sudahPulang = today?.checkOutAt != null;

    final statusMasukText = attendance.isLoading
        ? "Memuat..."
        : (!sudahMasuk ? "Belum presensi" : "Masuk ${_formatTime(today!.checkInAt!)}");

    final statusPulangText = attendance.isLoading
        ? "Memuat..."
        : (!sudahPulang ? "Belum presensi" : "Pulang ${_formatTime(today!.checkOutAt!)}");

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 980; // desktop layout
    final isDrawerMode = !isWide; // HP/tablet drawer

    final double sidebarWidth = isWide ? 220 : 280;

    final sidebar = _Sidebar(
      selectedIndex: _navIndex,
      onSelect: (i) async {
        setState(() => _navIndex = i);

        if (isDrawerMode && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (i == 0) return;

        if (i == 1) {
          await _openPage(PresensiPage());
          await context.read<AttendanceProvider>().loadToday();
          return;
        }
        if (i == 2) {
          await _openPage(RiwayatKehadiranPage());
          return;
        }
        if (i == 3) {
          await _openPage(PengajuanIzinPage());
          return;
        }
        if (i == 4) {
          await _openPage(ProfilPage());
          return;
        }
      },
      onLogout: () {
        if (isDrawerMode && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        _logout();
      },
    );

    final content = _DashboardBody(
      email: email,
      kelas: kelas,
      tanggalRingkas: tanggalRingkas,
      statusMasuk: statusMasukText,
      statusPulang: statusPulangText,
      announcements: _announcements,
      errorText: attendance.error,
      onOpenPresensi: () async {
        await _openPage(PresensiPage());
        await context.read<AttendanceProvider>().loadToday();
      },
      onOpenRiwayat: () async => _openPage(RiwayatKehadiranPage()),
      onOpenIzin: () async => _openPage(PengajuanIzinPage()),
      onOpenStatistik: () async => _openPage(StatistikKehadiranPage()),
      onOpenJadwal: () async => _openPage(JadwalPelajaranPage()),
      onOpenPengumuman: () async => _openPage(const PengumumanPage()),
      onOpenProfil: () async => _openPage(ProfilPage()),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1E3A8A),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "PresensiKu",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  color: Colors.white,
                )
              ],
            ),

      drawer: isWide
          ? null
          : Drawer(
              child: SizedBox(
                width: sidebarWidth,
                child: sidebar,
              ),
            ),

      body: isWide
          ? Row(
              children: [
                SizedBox(width: sidebarWidth, child: sidebar),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}

/* =========================
   DASHBOARD BODY
========================= */

class _DashboardBody extends StatelessWidget {
  final String email;
  final String kelas;
  final String tanggalRingkas;
  final String statusMasuk;
  final String statusPulang;

  // ✅ REVISI: dynamic agar bisa kategori/prioritas/tanggal/dibaca
  final List<Map<String, dynamic>> announcements;

  final String? errorText;

  final VoidCallback onOpenPresensi;
  final VoidCallback onOpenRiwayat;
  final VoidCallback onOpenIzin;
  final VoidCallback onOpenStatistik;
  final VoidCallback onOpenJadwal;
  final VoidCallback onOpenPengumuman;
  final VoidCallback onOpenProfil;

  const _DashboardBody({
    required this.email,
    required this.kelas,
    required this.tanggalRingkas,
    required this.statusMasuk,
    required this.statusPulang,
    required this.announcements,
    required this.errorText,
    required this.onOpenPresensi,
    required this.onOpenRiwayat,
    required this.onOpenIzin,
    required this.onOpenStatistik,
    required this.onOpenJadwal,
    required this.onOpenPengumuman,
    required this.onOpenProfil,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _banner(),
              const SizedBox(height: 14),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _leftColumn(context)),
                    const SizedBox(width: 14),
                    SizedBox(width: 360, child: _rightColumn(context)),
                  ],
                )
              else
                Column(
                  children: [
                    _leftColumn(context),
                    const SizedBox(height: 14),
                    _rightColumn(context),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Kelas $kelas • Ayo presensi tepat waktu.",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _leftColumn(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final maxW = c.maxWidth;
            final raw = (maxW - 24) / 3;
            final cardW = raw.clamp(105.0, isWide ? 200.0 : 150.0);
            final needsScroll = (cardW * 3 + 24) > maxW;

            final row = Row(
              children: [
                SizedBox(
                  width: cardW,
                  child: _miniStatCard(
                    title: "Tanggal",
                    value: tanggalRingkas,
                    icon: Icons.calendar_today,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: cardW,
                  child: _miniStatCard(
                    title: "Status Masuk",
                    value: statusMasuk,
                    icon: Icons.login,
                    color: const Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: cardW,
                  child: _miniStatCard(
                    title: "Status Pulang",
                    value: statusPulang,
                    icon: Icons.logout,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            );

            if (!needsScroll) return row;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: row,
            );
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Aksi Cepat", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text("Klik untuk melakukan presensi (PIN).",
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onOpenPresensi,
                icon: const Icon(Icons.fingerprint),
                label: const Text("Presensi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ✅ REVISI: Pengumuman Terbaru mengikuti card style
        _sectionCard(
          title: "Pengumuman Terbaru",
          trailing: TextButton(onPressed: onOpenPengumuman, child: const Text("Lihat semua")),
          child: Column(
            children: announcements.take(3).map((a) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HomeAnnouncementCard(
                  kategori: a["kategori"] as String,
                  prioritas: a["prioritas"] as String,
                  judul: a["judul"] as String,
                  isi: a["isi"] as String,
                  tanggal: a["tanggal"] as DateTime,
                  dibaca: a["dibaca"] as bool,
                  onTap: onOpenPengumuman,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _rightColumn(BuildContext context) {
    return Column(
      children: [
        _sectionCard(
          title: "Aturan Presensi",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ruleRow("Masuk", "06:00 – 07:00"),
              const SizedBox(height: 10),
              _ruleRow("Pulang", "15:30 – 16:00"),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 10),
              const Text("Catatan:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                "- Presensi menggunakan 1 PIN sekolah.\n- Sistem otomatis menolak jika di luar jam.\n- Riwayat bisa dilihat di menu Riwayat.",
                style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: "Shortcut",
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chipBtn("Riwayat", Icons.history, onOpenRiwayat),
              _chipBtn("Izin/Sakit", Icons.medical_services, onOpenIzin),
              _chipBtn("Statistik", Icons.bar_chart, onOpenStatistik),
              _chipBtn("Jadwal", Icons.schedule, onOpenJadwal),
              _chipBtn("Pengumuman", Icons.notifications, onOpenPengumuman),
              _chipBtn("Profil", Icons.person, onOpenProfil),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54, fontSize: 11), maxLines: 1),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, Widget? trailing, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _ruleRow(String label, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(time, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _chipBtn(String text, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: const Icon(Icons.circle, size: 0),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
      onPressed: onTap,
    );
  }
}

/* =========================
   PENGUMUMAN CARD (HOME)
========================= */

class _HomeAnnouncementCard extends StatelessWidget {
  final String kategori;
  final String prioritas;
  final String judul;
  final String isi;
  final DateTime tanggal;
  final bool dibaca;
  final VoidCallback onTap;

  const _HomeAnnouncementCard({
    required this.kategori,
    required this.prioritas,
    required this.judul,
    required this.isi,
    required this.tanggal,
    required this.dibaca,
    required this.onTap,
  });

  static const Color _blue = Color(0xFF2563EB);
  static const Color _blueDark = Color(0xFF1E40AF);

  @override
  Widget build(BuildContext context) {
    final icon = _iconForKategori(kategori);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: dibaca ? const Color(0xFFE2E8F0) : _blue.withOpacity(.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _blue.withOpacity(.12),
              child: Icon(icon, color: _blueDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MiniPill(text: kategori),
                      const SizedBox(width: 8),
                      _PriorityPillMini(prioritas: prioritas),
                      const Spacer(),
                      if (!dibaca)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _blue,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, height: 1.25),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _fmtDate(tanggal),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForKategori(String k) {
    final s = k.toLowerCase();
    if (s.contains("ujian")) return Icons.assignment_turned_in_rounded;
    if (s.contains("kegiatan")) return Icons.emoji_events_rounded;
    if (s.contains("sekolah")) return Icons.school_rounded;
    return Icons.notifications_rounded;
  }

  static String _fmtDate(DateTime d) {
    const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}

class _MiniPill extends StatelessWidget {
  final String text;
  const _MiniPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PriorityPillMini extends StatelessWidget {
  final String prioritas;
  const _PriorityPillMini({required this.prioritas});

  @override
  Widget build(BuildContext context) {
    final p = prioritas.toLowerCase();
    final Color c = p.contains("tinggi")
        ? const Color(0xFFDC2626)
        : p.contains("sedang")
            ? const Color(0xFFF59E0B)
            : const Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(.25)),
      ),
      child: Text(
        prioritas,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: c),
      ),
    );
  }
}

/* =========================
   SIDEBAR (RAMPING)
========================= */

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E3A8A),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.fingerprint, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "PresensiKu",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _item(0, Icons.dashboard, "Dashboard"),
                  _item(1, Icons.fingerprint, "Presensi"),
                  _item(2, Icons.history, "Riwayat"),
                  _item(3, Icons.medical_services, "Izin / Sakit"),
                  _item(4, Icons.person, "Profil"),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              dense: true,
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Logout", style: TextStyle(color: Colors.white)),
              onTap: onLogout,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _item(int idx, IconData icon, String title) {
    final active = idx == selectedIndex;
    return ListTile(
      dense: true,
      horizontalTitleGap: 10,
      leading: Icon(icon, size: 22, color: active ? Colors.amber : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: active ? Colors.amber : Colors.white,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onSelect(idx),
    );
  }
}
