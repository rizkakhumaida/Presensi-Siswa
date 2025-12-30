import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();

  Attendance? today;
  List<Attendance> history = [];

  bool isLoading = false;
  String? error;

  // =============================
  // KONFIG JAM PRESENSI (WIB)
  // Masuk  : 06:00 - 07:00
  // Pulang : 15:30 - 16:00
  // =============================
  DateTime _todayAt(int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  DateTime get inStartToday => _todayAt(6, 0);
  DateTime get inEndToday => _todayAt(7, 0);

  DateTime get outStartToday => _todayAt(15, 30);
  DateTime get outEndToday => _todayAt(16, 0);

  bool _isNowBetween(DateTime start, DateTime end) {
    final now = DateTime.now();
    return !now.isBefore(start) && !now.isAfter(end);
  }

  String _fmtHM(DateTime d) =>
      "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

  // =============================
  // LOADERS
  // =============================
  Future<void> loadToday() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      today = await _service.getToday();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory({int limit = 60}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      history = await _service.getHistory(limit: limit);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =============================
  // CREATE: CHECK-IN
  // =============================
  Future<void> checkIn() async {
    try {
      // Validasi status dulu
      if (today?.checkInAt != null) {
        throw Exception("Anda sudah presensi masuk hari ini.");
      }
      // Validasi jam
      if (!_isNowBetween(inStartToday, inEndToday)) {
        throw Exception(
          "Presensi masuk hanya pukul ${_fmtHM(inStartToday)}–${_fmtHM(inEndToday)}.",
        );
      }

      isLoading = true;
      error = null;
      notifyListeners();

      today = await _service.checkIn();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =============================
  // UPDATE: CHECK-OUT
  // =============================
  Future<void> checkOut() async {
    try {
      // Validasi urutan
      if (today?.checkInAt == null) {
        throw Exception("Anda belum presensi masuk. Silakan presensi masuk dulu.");
      }
      if (today?.checkOutAt != null) {
        throw Exception("Anda sudah presensi pulang hari ini.");
      }
      // Validasi jam
      if (!_isNowBetween(outStartToday, outEndToday)) {
        throw Exception(
          "Presensi pulang hanya pukul ${_fmtHM(outStartToday)}–${_fmtHM(outEndToday)}.",
        );
      }

      isLoading = true;
      error = null;
      notifyListeners();

      today = await _service.checkOut();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // DELETE (opsional)
  Future<void> deleteAttendance(String id) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _service.deleteById(id);
      await loadToday();
      await loadHistory();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearLocal() {
    today = null;
    history = [];
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
