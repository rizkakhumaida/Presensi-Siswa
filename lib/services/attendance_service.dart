import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance.dart';

class AttendanceService {
  final SupabaseClient _sb = Supabase.instance.client;

  String _requireUserId() {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) throw Exception("User belum login.");
    return uid;
  }

  String _dateKey(DateTime dt) {
    final local = dt.toLocal();
    final d = DateTime(local.year, local.month, local.day);
    // YYYY-MM-DD
    return d.toIso8601String().substring(0, 10);
  }

  // ===== CREATE CHECK-IN (AMAN: tidak overwrite check-in yang sudah ada) =====
  Future<Attendance> checkIn({DateTime? at}) async {
    final uid = _requireUserId();
    final now = (at ?? DateTime.now()).toLocal();
    final dateKey = _dateKey(now);

    // cek existing dulu
    final existing = await _sb
        .from('attendances')
        .select()
        .eq('user_id', uid)
        .eq('date', dateKey)
        .maybeSingle();

    // kalau sudah ada check_in_at -> tolak
    if (existing != null && existing['check_in_at'] != null) {
      throw Exception("Presensi masuk sudah tercatat.");
    }

    // jika belum ada record -> insert
    if (existing == null) {
      final row = await _sb
          .from('attendances')
          .insert({
            'user_id': uid,
            'date': dateKey,
            'check_in_at': now.toIso8601String(),
          })
          .select()
          .single();

      return Attendance.fromMap(row);
    }

    // jika ada record tapi check_in_at null -> update
    final updated = await _sb
        .from('attendances')
        .update({'check_in_at': now.toIso8601String()})
        .eq('id', existing['id'])
        .select()
        .single();

    return Attendance.fromMap(updated);
  }

  // ===== READ TODAY =====
  Future<Attendance?> getToday() async {
    final uid = _requireUserId();
    final todayKey = _dateKey(DateTime.now());

    final row = await _sb
        .from('attendances')
        .select()
        .eq('user_id', uid)
        .eq('date', todayKey)
        .maybeSingle();

    if (row == null) return null;
    return Attendance.fromMap(row);
  }

  // ===== UPDATE CHECK-OUT =====
  Future<Attendance> checkOut({DateTime? at}) async {
    final uid = _requireUserId();
    final now = (at ?? DateTime.now()).toLocal();
    final todayKey = _dateKey(DateTime.now());

    final existing = await _sb
        .from('attendances')
        .select()
        .eq('user_id', uid)
        .eq('date', todayKey)
        .maybeSingle();

    if (existing == null || existing['check_in_at'] == null) {
      throw Exception("Belum presensi masuk. Silakan presensi masuk dulu.");
    }

    if (existing['check_out_at'] != null) {
      throw Exception("Presensi pulang sudah tercatat.");
    }

    final updated = await _sb
        .from('attendances')
        .update({'check_out_at': now.toIso8601String()})
        .eq('id', existing['id'])
        .select()
        .single();

    return Attendance.fromMap(updated);
  }

  // ===== READ HISTORY =====
  Future<List<Attendance>> getHistory({int limit = 60}) async {
    final uid = _requireUserId();

    final rows = await _sb
        .from('attendances')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: false)
        .limit(limit);

    return (rows as List)
        .map((e) => Attendance.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ===== DELETE (opsional) =====
  Future<void> deleteById(String id) async {
    final uid = _requireUserId();
    await _sb.from('attendances').delete().eq('id', id).eq('user_id', uid);
  }
}
