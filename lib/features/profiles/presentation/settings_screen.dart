import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'الإعدادات' : 'Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            isArabic ? 'اللغة' : 'Language',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'ar', label: Text('العربية')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (selection) => ref
                .read(appLocaleProvider.notifier)
                .setLanguage(selection.first),
          ),
        ],
      ),
    );
  }
}