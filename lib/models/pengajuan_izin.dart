class PengajuanIzin {
  final String? id;
  final String userId;
  final String jenisPengajuan; // Izin / Sakit
  final String alasan;
  final String status; // Menunggu / Disetujui / Ditolak
  final String? fileName; // optional
  final DateTime createdAt;
  final String? catatanAdmin; // optional

  const PengajuanIzin({
    this.id,
    required this.userId,
    required this.jenisPengajuan,
    required this.alasan,
    required this.status,
    required this.createdAt,
    this.fileName,
    this.catatanAdmin,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'jenis_pengajuan': jenisPengajuan,
        'alasan': alasan,
        'status': status,
        'file_name': fileName,
        'catatan_admin': catatanAdmin,
        'created_at': createdAt.toIso8601String(),
      };

  factory PengajuanIzin.fromMap(Map<String, dynamic> map) {
    return PengajuanIzin(
      id: map['id']?.toString(),
      userId: map['user_id'] ?? '',
      jenisPengajuan: map['jenis_pengajuan'] ?? '',
      alasan: map['alasan'] ?? '',
      status: map['status'] ?? 'Menunggu',
      fileName: map['file_name'],
      catatanAdmin: map['catatan_admin'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
