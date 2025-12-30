import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:inventory/models/pengajuan_izin.dart';
import 'package:inventory/pages/pengajuan/pengajuan_detail_page.dart';

class PengajuanIzinPage extends StatefulWidget {
  const PengajuanIzinPage({super.key});

  @override
  State<PengajuanIzinPage> createState() => _PengajuanIzinPageState();
}

class _PengajuanIzinPageState extends State<PengajuanIzinPage> {
  final _formKey = GlobalKey<FormState>();
  final _alasanCtrl = TextEditingController();

  String _tipe = "Izin";
  String _status = "Menunggu";

  PlatformFile? _pickedFile;
  String? _fileName;

  @override
  void dispose() {
    _alasanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _pickedFile = result.files.single;
      _fileName = _pickedFile!.name;
    });
  }

  void _removeFile() {
    setState(() {
      _pickedFile = null;
      _fileName = null;
    });
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final pengajuan = PengajuanIzin(
      userId: "siswa_001", // nanti ganti dari Supabase Auth
      jenisPengajuan: _tipe,
      alasan: _alasanCtrl.text.trim(),
      status: "Menunggu",
      fileName: _fileName,
      createdAt: DateTime.now(),
      catatanAdmin: null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pengajuan berhasil dikirim. Menunggu verifikasi."),
      ),
    );

    _alasanCtrl.clear();
    setState(() {
      _tipe = "Izin";
      _status = "Menunggu";
      _pickedFile = null;
      _fileName = null;
    });

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PengajuanDetailPage(pengajuan: pengajuan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white, // back + icon jadi putih
        title: const Text(
          "Ajukan Izin / Sakit",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Accent halus biar tidak flat
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E3A8A).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withOpacity(0.08),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: _tintedCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _headerBanner(
                          status: _status,
                          tipe: _tipe,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Jenis Pengajuan",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _tipe,
                          items: const [
                            DropdownMenuItem(value: "Izin", child: Text("Izin")),
                            DropdownMenuItem(value: "Sakit", child: Text("Sakit")),
                          ],
                          onChanged: (v) => setState(() => _tipe = v ?? "Izin"),
                          decoration: _fieldDecoration(
                            hintText: "",
                            icon: Icons.assignment_rounded,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          "Alasan / Keterangan",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _alasanCtrl,
                          minLines: 3,
                          maxLines: 5,
                          decoration: _fieldDecoration(
                            hintText: "Contoh: Izin karena ada keperluan keluarga...",
                            icon: Icons.edit_note_rounded,
                            alignIconTop: true,
                          ),
                          validator: (val) {
                            final v = val?.trim() ?? "";
                            if (v.isEmpty) return "Alasan wajib diisi.";
                            if (v.length < 8) return "Alasan terlalu singkat (min. 8 karakter).";
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Bukti Surat (Opsional)",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        _uploadBox(
                          fileName: _fileName,
                          onPick: _pickFile,
                          onRemove: _removeFile,
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.send_rounded),
                            label: const Text(
                              "Kirim Pengajuan",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Status awal: $_status. Admin akan memverifikasi pengajuan Anda.",
                                  style: const TextStyle(
                                    color: Color(0xFF92400E),
                                    fontWeight: FontWeight.w700,
                                  ),
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
        ],
      ),
    );
  }

  // =========================
  // UI HELPERS
  // =========================

  Widget _tintedCard({required Widget child}) {
    // Card utama (TIDAK PUTIH) + lebih kontras dari background
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // tinted biru-abu biar “muncul” di background
            gradient: const LinearGradient(
              colors: [Color(0xFFF1F5FF), Color(0xFFEFF6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCE7FF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
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

  Widget _headerBanner({required String status, required String tipe}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Form Pengajuan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Silakan isi data pengajuan dan unggah bukti jika diperlukan.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.90),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _pill(
                            icon: Icons.circle,
                            iconColor: const Color(0xFFF59E0B),
                            text: "Status: $status",
                          ),
                          _pill(
                            icon: Icons.circle,
                            iconColor: const Color(0xFF60A5FA),
                            text: "Tipe: $tipe",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
    bool alignIconTop = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
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
        borderSide: const BorderSide(color: Color(0xFF93C5FD), width: 1.5),
      ),
      prefixIcon: alignIconTop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Icon(icon),
            )
          : Icon(icon),
    );
  }

  Widget _uploadBox({
    required String? fileName,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(fileName == null ? "Upload Bukti" : "Ganti File"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    foregroundColor: const Color(0xFF1E3A8A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (fileName != null)
                IconButton(
                  tooltip: "Hapus file",
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Format: JPG/PNG/PDF",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          if (fileName != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF1E3A8A)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
