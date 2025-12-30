import 'package:flutter/material.dart';

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  // Dummy data (nanti bisa dari Supabase)
  final List<Map<String, dynamic>> _pengumuman = [
    {
      "kategori": "Info Sekolah",
      "judul": "Libur Semester",
      "isi": "Libur semester mulai 20 Desember. Pastikan semua tugas sudah dikumpulkan.",
      "tanggal": DateTime(2025, 12, 20),
      "prioritas": "Sedang", // Rendah/Sedang/Tinggi
      "dibaca": false,
    },
    {
      "kategori": "Info Ujian",
      "judul": "UAS Dimulai",
      "isi": "Ujian akhir semester dimulai 10 Desember. Cek jadwal di menu Jadwal.",
      "tanggal": DateTime(2025, 12, 10),
      "prioritas": "Tinggi",
      "dibaca": true,
    },
    {
      "kategori": "Info Kegiatan",
      "judul": "Lomba Olahraga Antar Kelas",
      "isi": "Lomba olahraga antar kelas akan dilaksanakan 5 Januari. Pendaftaran via wali kelas.",
      "tanggal": DateTime(2026, 1, 5),
      "prioritas": "Rendah",
      "dibaca": false,
    },
  ];

  final TextEditingController _searchC = TextEditingController();
  String _selectedKategori = "Semua";

  // Theme colors (Blue)
  static const Color _blue = Color(0xFF2563EB);
  static const Color _blueDark = Color(0xFF1E40AF);

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // UI refresh (nanti ganti fetch dari Supabase)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchC.text.trim().toLowerCase();

    return _pengumuman.where((p) {
      final kategoriOk =
          _selectedKategori == "Semua" || p["kategori"] == _selectedKategori;
      final judul = (p["judul"] as String).toLowerCase();
      final isi = (p["isi"] as String).toLowerCase();
      final searchOk = q.isEmpty || judul.contains(q) || isi.contains(q);
      return kategoriOk && searchOk;
    }).toList()
      ..sort((a, b) =>
          (b["tanggal"] as DateTime).compareTo(a["tanggal"] as DateTime));
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _pengumuman.where((e) => e["dibaca"] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Pengumuman"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: const _BlueAppBarBg(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _Badge(text: "$unreadCount belum dibaca"),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final isMobile = w < 600;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: isMobile ? double.infinity : 980),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 14 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderPanel(
                          searchController: _searchC,
                          selectedKategori: _selectedKategori,
                          onKategoriChanged: (v) =>
                              setState(() => _selectedKategori = v),
                          onSearchChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "Daftar Pengumuman (${_filtered.length})",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (_filtered.isEmpty)
                          _EmptyState(
                            onClear: () {
                              _searchC.clear();
                              setState(() => _selectedKategori = "Semua");
                            },
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final p = _filtered[i];
                              return _AnnouncementCard(
                                kategori: p["kategori"] as String,
                                judul: p["judul"] as String,
                                isi: p["isi"] as String,
                                tanggal: p["tanggal"] as DateTime,
                                prioritas: p["prioritas"] as String,
                                dibaca: p["dibaca"] as bool,
                                onTap: () {
                                  setState(() => p["dibaca"] = true);
                                  _showDetail(context, p);
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> p) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _KategoriPill(kategori: p["kategori"] as String),
                  const SizedBox(width: 8),
                  _PriorityPill(prioritas: p["prioritas"] as String),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                p["judul"] as String,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                _fmtDate(p["tanggal"] as DateTime),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                p["isi"] as String,
                style: const TextStyle(height: 1.35),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
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
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}

/* =========================
   APPBAR BG (BLUE GRADIENT)
========================= */

class _BlueAppBarBg extends StatelessWidget {
  const _BlueAppBarBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

/* =========================
   HEADER PANEL (Search + Filter)
========================= */

class _HeaderPanel extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedKategori;
  final VoidCallback onSearchChanged;
  final ValueChanged<String> onKategoriChanged;

  const _HeaderPanel({
    required this.searchController,
    required this.selectedKategori,
    required this.onSearchChanged,
    required this.onKategoriChanged,
  });

  static const Color _blue = Color(0xFF2563EB);
  static const Color _blueDark = Color(0xFF1E40AF);

  @override
  Widget build(BuildContext context) {
    final items = const ["Semua", "Info Sekolah", "Info Ujian", "Info Kegiatan"];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: "Cari pengumuman (judul / isi)...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _blue, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((k) {
              final active = k == selectedKategori;
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onKategoriChanged(k),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: active
                        ? _blue.withOpacity(.12)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active
                          ? _blue.withOpacity(.35)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    k,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: active ? _blueDark : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

/* =========================
   CARD PENGUMUMAN
========================= */

class _AnnouncementCard extends StatelessWidget {
  final String kategori;
  final String judul;
  final String isi;
  final DateTime tanggal;
  final String prioritas;
  final bool dibaca;
  final VoidCallback onTap;

  const _AnnouncementCard({
    required this.kategori,
    required this.judul,
    required this.isi,
    required this.tanggal,
    required this.prioritas,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(
            color: dibaca ? const Color(0xFFE2E8F0) : _blue.withOpacity(.25),
          ),
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
                      _KategoriPill(kategori: kategori),
                      const SizedBox(width: 8),
                      _PriorityPill(prioritas: prioritas),
                      const Spacer(),
                      if (!dibaca) const _Dot(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
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
    const months = [
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
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}

/* =========================
   SMALL WIDGETS
========================= */

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.22)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _KategoriPill extends StatelessWidget {
  final String kategori;
  const _KategoriPill({required this.kategori});

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
        kategori,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final String prioritas;
  const _PriorityPill({required this.prioritas});

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

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 46, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            "Tidak ada pengumuman yang cocok.",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Coba ubah kata kunci pencarian atau reset filter kategori.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: const Text("Reset Filter"),
          )
        ],
      ),
    );
  }
}
