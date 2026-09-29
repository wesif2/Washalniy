import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/driver_repository.dart';
import 'providers/driver_providers.dart';

class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends ConsumerState<DriverOnboardingScreen> {
  final _nationalIdController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _nationalIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nationalId = _nationalIdController.text.trim();
    if (nationalId.isEmpty) {
      setState(() => _errorText = 'الرقم القومي مطلوب');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await ref.read(driverRepositoryProvider).upsertDriverProfile(
        nationalId: nationalId,
      );
      if (!mounted) return;
      ref.invalidate(currentDriverProvider);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = 'تعذر إرسال الطلب. حاول مرة أخرى.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم كـ سائق'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Driver application',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'يمكنك إنشاء ملفك، ولكن الرحلات لا يمكن أن تُنشر قبل التحقق.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'الرقم القومي',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('إرسال الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
