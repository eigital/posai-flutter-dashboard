import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bootstrap/app_state.dart';
import 'bootstrap/auth_refresh.dart';
import 'config/supabase_config.dart';
import 'integrations/supabase/supabase_client.dart';
import 'router/app_router.dart';
import 'services/auth_repository.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_scope.dart';

final ThemeController themeController = ThemeController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseConfigured) {
    await initSupabase();
    initializeStorageBuckets().ignore();
  }

  final prefs = await SharedPreferences.getInstance();
  authRepository = AuthRepository(prefs);
  authRefresh = AuthRefreshNotifier();
  appRouter = createAppRouter();
  runApp(const EatOsDashboardApp());
}

class EatOsDashboardApp extends StatelessWidget {
  const EatOsDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return ThemeControllerScope(
          controller: themeController,
          child: MaterialApp.router(
            title: 'eatOS',
            debugShowCheckedModeBanner: false,
            themeMode: themeController.mode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}
