import 'package:go_router/go_router.dart';

import 'package:eo_dashboard_flutter/bootstrap/auth_refresh.dart';
import 'package:eo_dashboard_flutter/services/auth_repository.dart';

/// Initialized in [main] before [runApp].
late AuthRepository authRepository;

/// Notifies [GoRouter] after login/logout. Initialized in [main].
late AuthRefreshNotifier authRefresh;

/// Global router — initialized in [main] (and in tests).
late GoRouter appRouter;
