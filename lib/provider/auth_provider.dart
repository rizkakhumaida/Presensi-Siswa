import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => SupabaseService().currentUser;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService().signIn(email, password);
      if (response.user != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Login gagal";
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String email, String password, String nama, String nimNip) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService().signUp(email, password);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (response.user != null && userId != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': userId,
          'email': email,
          'nama': nama,
          'nim_nip': nimNip,
        });
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Registrasi gagal";
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await SupabaseService().signOut();
    notifyListeners();
  }
}
