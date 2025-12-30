import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/attendance_provider.dart';
import '../widgets/pin_dialog.dart';

class PresensiPage extends StatefulWidget {
  PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage>
    with SingleTickerProviderStateMixin {
  static String pinPresensi = "123456";

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<AttendanceProvider>().loadToday();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return "${_two(local.hour)}:${_two(local.minute)}";
  }

  String _formatDate(DateTime dt) {
    const bulan = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    final local = dt.toLocal();
    return "${local.day} ${bulan[local.month - 1]} ${local.year}";
  }

  bool _withinWindow(DateTime now, int sh, int sm, int eh, int em) {
    final start = DateTime(now.year, now.month, now.day, sh, sm);
    final end = DateTime(now.year, now.month, now.day, eh, em);
    return !now.isBefore(start) && now.isBefore(end);
  }

  Future<void> _doPresensiMasuk() async {
    final okPin = await PinDialog.verify(
      context: context,
      title: "Verifikasi PIN Presensi",
      subtitle: "Masukkan PIN untuk presensi MASUK.",
      expectedPin: pinPresensi,
    );
    if (!okPin) return;

    final provider = context.read<AttendanceProvider>();
    try {
      await provider.checkIn();
      await provider.loadToday();

      if (!mounted) return;
      final t = provider.today?.checkInAt;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t == null
                ? "Presensi masuk berhasil."
                : "Presensi masuk berhasil: ${_formatTime(t)}",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _doPresensiPulang() async {
    final okPin = await PinDialog.verify(
      context: context,
      title: "Verifikasi PIN Presensi",
      subtitle: "Masukkan PIN untuk presensi PULANG.",
      expectedPin: pinPresensi,
    );
    if (!okPin) return;

    final provider = context.read<AttendanceProvider>();
    try {
      await provider.checkOut();
      await provider.loadToday();

      if (!mounted) return;
      final t = provider.today?.checkOutAt;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t == null
                ? "Presensi pulang berhasil."
                : "Presensi pulang berhasil: ${_formatTime(t)}",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _resetDemoToday() async {
    final provider = context.read<AttendanceProvider>();
    final today = provider.today;
    if (today == null) return;

    try {
      await provider.deleteAttendance(today.id);
      await provider.loadToday();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reset presensi hari ini berhasil (demo)."),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final today = attendance.today;

    final sudahMasuk = today?.checkInAt != null;
    final sudahPulang = today?.checkOutAt != null;

    final now = DateTime.now();
    final bolehMasuk = _withinWindow(now, 6, 0, 7, 0);
    final bolehPulang = _withinWindow(now, 15, 30, 16, 0);

    final statusMasuk = !sudahMasuk
        ? "Belum presensi"
        : "Masuk ${_formatTime(today!.checkInAt!)}";

    final statusPulang = !sudahPulang
        ? "Belum presensi"
        : "Pulang ${_formatTime(today!.checkOutAt!)}";

    String primaryLabel;
    IconData primaryIcon;
    VoidCallback? primaryOnTap;
    String helperText;

    if (attendance.isLoading) {
      primaryLabel = "Memuat...";
      primaryIcon = Icons.hourglass_top;
      primaryOnTap = null;
      helperText = "Mengambil data presensi...";
    } else if (!sudahMasuk) {
      primaryLabel = "Presensi Masuk";
      primaryIcon = Icons.login;
      primaryOnTap = bolehMasuk ? () => _doPresensiMasuk() : null;
      helperText = bolehMasuk
          ? "Silakan presensi masuk sekarang."
          : "Di luar jam presensi masuk (06:00–07:00).";
    } else if (sudahMasuk && !sudahPulang) {
      primaryLabel = "Presensi Pulang";
      primaryIcon = Icons.logout_rounded;
      primaryOnTap = bolehPulang ? () => _doPresensiPulang() : null;
      helperText = bolehPulang
          ? "Silakan presensi pulang sekarang."
          : "Di luar jam presensi pulang (15:30–16:00).";
    } else {
      primaryLabel = "Presensi Selesai";
      primaryIcon = Icons.check_circle;
      primaryOnTap = null;
      helperText = "Presensi hari ini sudah lengkap. Tidak bisa absen ulang.";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // ===== HEADER KEREN (SEPERTI GAMBAR ANDA) =====
      appBar: AppBar(
        toolbarHeight: 72,
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF283593),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Presensi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (kDebugMode)
            TextButton(
              onPressed: _resetDemoToday,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: const Text("Reset"),
            ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: const _KerenHeaderBackground(),
      ),

      body: Stack(
        children: [
          // background gradient halus
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3E54AC), Color(0xFF7B8AFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            top: false, // karena AppBar sudah aman
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: Column(
                    children: [
                      // header konten (card) biar tidak kosong setelah AppBar
                      _glassCard(
                        child: Row(
                          children: [
                            _iconBubble(Icons.fingerprint),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Presensi Hari Ini",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Pastikan presensi sesuai jam yang ditentukan.",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.90),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _miniChip(
                                        icon: Icons.calendar_today,
                                        text: _formatDate(now),
                                      ),
                                      _miniChip(
                                        icon: Icons.schedule,
                                        text: "Waktu: ${_formatTime(now)}",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _glassCard(
                        child: Row(
                          children: [
                            _iconBubble(Icons.schedule),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Aturan Jam Presensi",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Masuk: 06:00–07:00 • Pulang: 15:30–16:00",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Status Hari Ini",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _iconBubble(Icons.login),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _statusLine(label: "Masuk", value: statusMasuk),
                                ),
                                const SizedBox(width: 10),
                                _statusBadge(text: sudahMasuk ? "Tercatat" : "Belum", ok: sudahMasuk),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _iconBubble(Icons.logout_rounded),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _statusLine(label: "Pulang", value: statusPulang),
                                ),
                                const SizedBox(width: 10),
                                _statusBadge(text: sudahPulang ? "Tercatat" : "Belum", ok: sudahPulang),
                              ],
                            ),
                            if (attendance.error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.35)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade100),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        attendance.error!,
                                        style: TextStyle(
                                          color: Colors.red.shade100,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Aksi Presensi",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              helperText,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),

                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (context, child) {
                                final enabled = primaryOnTap != null;
                                final scale = enabled ? (1.0 + (_pulseCtrl.value * 0.03)) : 1.0;

                                return Transform.scale(
                                  scale: scale,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: primaryOnTap,
                                      icon: Icon(primaryIcon),
                                      label: Text(
                                        primaryLabel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: enabled
                                            ? const Color(0xFF1E3A8A)
                                            : Colors.white.withOpacity(0.18),
                                        foregroundColor: Colors.white,
                                        elevation: enabled ? 10 : 0,
                                        shadowColor: Colors.black.withOpacity(0.25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),
                            Text(
                              "Catatan: Presensi menggunakan 1 PIN sekolah (123456).",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
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
        ],
      ),
    );
  }

  // ===== UI HELPERS =====

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _iconBubble(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _miniChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusLine({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge({required String text, required bool ok}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ok
            ? Colors.greenAccent.withOpacity(0.22)
            : Colors.redAccent.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: ok
              ? Colors.greenAccent.withOpacity(0.35)
              : Colors.redAccent.withOpacity(0.35),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _KerenHeaderBackground extends StatelessWidget {
  const _KerenHeaderBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3E54AC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // arc kiri (ini yang bikin mirip header di gambar)
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 260,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(120),
                bottomRight: Radius.circular(120),
              ),
            ),
          ),
        ),

        // aksen lingkaran
        Positioned(
          right: -60,
          top: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
        ),
        Positioned(
          right: 40,
          bottom: -60,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }
}
