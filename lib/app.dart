import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/role_select/presentation/role_select_screen.dart';

class WassalniApp extends StatelessWidget {
  const WassalniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'وصّلني',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const RoleSelectScreen(),
    );
  }
}
