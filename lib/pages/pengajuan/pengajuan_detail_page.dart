import 'package:flutter/material.dart';
import 'package:inventory/models/pengajuan_izin.dart';

class PengajuanDetailPage extends StatelessWidget {
  final PengajuanIzin pengajuan;

  const PengajuanDetailPage({super.key, required this.pengajuan});

  Color _statusColor(String status) {
    switch (status) {
      case "Disetujui":
        return const Color(0xFF16A34A);
      case "Ditolak":
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Disetujui":
        return Icons.verified_rounded;
      case "Ditolak":
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_bottom_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$d-$m-$y $hh:$mm";
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(pengajuan.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Detail Pengajuan"),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_statusIcon(pengajuan.status), color: statusColor),
                        const SizedBox(width: 8),
                        Text(
                          pengajuan.status,
                          style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _RowItem("Jenis", pengajuan.jenisPengajuan),
                    _RowItem("Tanggal", _formatDate(pengajuan.createdAt)),
                    _RowItem("User ID", pengajuan.userId),

                    const SizedBox(height: 14),
                    const Text("Alasan / Keterangan", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(pengajuan.alasan),
                    ),

                    const SizedBox(height: 14),
                    const Text("Lampiran Bukti", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      (pengajuan.fileName == null || pengajuan.fileName!.trim().isEmpty)
                          ? "Tidak ada lampiran"
                          : pengajuan.fileName!,
                      style: const TextStyle(color: Colors.black54),
                    ),

                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Kembali"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
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
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  const _RowItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.black54))),
          const Text(": "),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
