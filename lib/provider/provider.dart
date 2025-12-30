import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'item_provider.dart';

class AppProviders {
  static final providers = [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ItemProvider()),
  ];
}
