class Attendance {
  final String id;
  final String userId;

  /// HANYA tanggal (YYYY-MM-DD), tanpa jam
  final DateTime date;

  /// Jam presensi masuk (lokal/WIB)
  final DateTime? checkInAt;

  /// Jam presensi pulang (lokal/WIB)
  final DateTime? checkOutAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkInAt,
    this.checkOutAt,
  });

  /// ===== FROM DATABASE (SUPABASE) =====
  factory Attendance.fromMap(Map<String, dynamic> map) {
    // Pastikan kolom date benar-benar hanya tanggal (YYYY-MM-DD)
    final dateStr = map['date'] as String;
    final parts = dateStr.split('-');

    return Attendance(
      id: map['id'] as String,
      userId: map['user_id'] as String,

      // Date tanpa efek timezone (AMAN)
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),

      // Jam presensi selalu lokal (WIB)
      checkInAt: map['check_in_at'] != null
          ? DateTime.parse(map['check_in_at'] as String).toLocal()
          : null,

      checkOutAt: map['check_out_at'] != null
          ? DateTime.parse(map['check_out_at'] as String).toLocal()
          : null,
    );
  }

  /// ===== TO DATABASE (INSERT / UPDATE) =====
  Map<String, dynamic> toInsertMap() => {
        'user_id': userId,

        // Simpan date sebagai YYYY-MM-DD (tanpa jam)
        'date':
            "${date.year.toString().padLeft(4, '0')}-"
            "${date.month.toString().padLeft(2, '0')}-"
            "${date.day.toString().padLeft(2, '0')}",

        // Jam disimpan sebagai ISO lokal
        'check_in_at': checkInAt?.toLocal().toIso8601String(),
        'check_out_at': checkOutAt?.toLocal().toIso8601String(),
      };
}
