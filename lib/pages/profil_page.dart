import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // Dummy data (nantinya bisa dari provider / supabase)
  final String nama = "Rizka Khumaida";
  final String nis = "123456";
  final String kelas = "XI IPA 1";

  final int hadir = 20;
  final int telat = 3;
  final int izin = 2;
  final int alpha = 1;

  @override
  Widget build(BuildContext context) {
    final total = hadir + telat + izin + alpha;
    final hadirPct = total == 0 ? 0.0 : hadir / total;
    final isPhone = MediaQuery.of(context).size.width < 600;

    // Ini penting untuk mode inspect/web: supaya teks tidak membesar ekstrem dan bikin overflow
    final media = MediaQuery.of(context);
    final clampedScale = media.textScaleFactor.clamp(1.0, 1.10);

    return MediaQuery(
      data: media.copyWith(textScaleFactor: clampedScale),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),

        /* ================= APP BAR (OPSI A) ================= */
        appBar: AppBar(
          title: const Text("Profil Saya"),
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: "Kembali",
                  onPressed: () => Navigator.pop(context),
                )
              : Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    tooltip: "Menu",
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
        ),

        /* ================= DRAWER ================= */
        drawer: _buildDrawer(context),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isPhone ? 12 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    _profileCard(isPhone),
                    const SizedBox(height: 14),

                    _card(
                      title: "Ringkasan Kehadiran",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.insights,
                                  color: Color(0xFF1E3A8A), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Total Rekap: $total",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "${(hadirPct * 100).toStringAsFixed(0)}% Hadir",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: hadirPct,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF16A34A)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Persentase hadir dihitung dari total rekap (hadir, telat, izin, alpha).",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _card(
                      title: "Rekap Kehadiran",
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isPhone ? 2 : 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,

                        // KUNCI FIX: bikin card lebih tinggi di HP
                        // (sebelumnya terlalu tinggi nilainya -> card terlalu pendek)
                        childAspectRatio: isPhone ? 1.85 : 2.8,

                        children: [
                          _stat(
                            label: "Hadir",
                            value: hadir,
                            icon: Icons.check_circle_rounded,
                            color: const Color(0xFF16A34A),
                          ),
                          _stat(
                            label: "Telat",
                            value: telat,
                            icon: Icons.access_time_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                          _stat(
                            label: "Izin",
                            value: izin,
                            icon: Icons.info_rounded,
                            color: const Color(0xFF2563EB),
                          ),
                          _stat(
                            label: "Alpha",
                            value: alpha,
                            icon: Icons.cancel_rounded,
                            color: const Color(0xFFDC2626),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _card(
                      title: "Aksi",
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.lock_reset),
                              label: const Text("Edit Password"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334155),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.logout),
                              label: const Text("Logout"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ================= COMPONENTS ================= */

  Widget _profileCard(bool isPhone) {
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: isPhone ? 32 : 38,
            backgroundColor: const Color(0xFFE2E8F0),
            child: const Icon(Icons.person,
                size: 42, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip("NIS: $nis"),
                    _chip("Kelas: $kelas"),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Jika ada kesalahan data, hubungi admin/wali kelas.",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  // Card statistik yang aman dari overflow
  Widget _stat({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$value",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1E3A8A),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text("PresensiKu",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24),
              _drawerItem(Icons.dashboard, "Dashboard"),
              _drawerItem(Icons.fingerprint, "Presensi"),
              _drawerItem(Icons.history, "Riwayat"),
              _drawerItem(Icons.assignment, "Izin / Sakit"),
              _drawerItem(Icons.person, "Profil", active: true),
              const Spacer(),
              const Divider(color: Colors.white24),
              _drawerItem(Icons.logout, "Logout", danger: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label,
      {bool active = false, bool danger = false}) {
    final color = danger
        ? const Color(0xFFDC2626)
        : active
            ? const Color(0xFFFACC15)
            : Colors.white;

    return ListTile(
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: active ? FontWeight.bold : FontWeight.w600)),
      onTap: () {},
    );
  }
}
