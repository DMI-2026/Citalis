import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'routing/app_router.dart';
import 'ui/core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(providers: fakeRepositories(), child: const CitalisApp()),
  );
}

class CitalisApp extends StatelessWidget {
  const CitalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citalis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      onGenerateRoute: onGenerateRoute,
    );
  }
}
