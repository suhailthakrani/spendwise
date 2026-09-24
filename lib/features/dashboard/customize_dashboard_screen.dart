import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/dashboard_layout.dart';
import '../../providers/preferences_providers.dart';

class CustomizeDashboardScreen extends ConsumerStatefulWidget {
  const CustomizeDashboardScreen({super.key});

  @override
  ConsumerState<CustomizeDashboardScreen> createState() =>
      _CustomizeDashboardScreenState();
}

class _CustomizeDashboardScreenState
    extends ConsumerState<CustomizeDashboardScreen> {
  late List<DashboardWidgetId> _widgets;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(preferencesProvider).valueOrNull;
      final layout = DashboardLayout.fromJson(prefs?.dashboardLayoutJson);
      setState(() {
        _widgets = [...layout.widgets];
        _initialized = true;
      });
    });
  }

  Future<void> _save() async {
    final layout = DashboardLayout(widgets: List.unmodifiable(_widgets));
    await ref
        .read(preferencesRepositoryProvider)
        .setDashboardLayoutJson(layout.toJson());
    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Home layout saved')),
    );
  }

  void _toggle(DashboardWidgetId id) {
    setState(() {
      if (_widgets.contains(id)) {
        if (_widgets.length <= 1) return;
        _widgets.remove(id);
      } else {
        _widgets.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hidden = DashboardWidgetId.values
        .where((id) => !_widgets.contains(id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize home'),
        actions: [
          TextButton(
            onPressed: _initialized ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                8,
                AppSpacing.page,
                AppSpacing.navClearance,
              ),
              children: [
                Text(
                  'Visible widgets',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _widgets.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _widgets.removeAt(oldIndex);
                        _widgets.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final id = _widgets[index];
                      return ListTile(
                        key: ValueKey(id.name),
                        leading: const AppIcon(AppIcons.sort, size: 20),
                        title: Text(id.label),
                        trailing: IconButton(
                          tooltip: 'Hide',
                          onPressed: () => _toggle(id),
                          icon: const AppIcon(AppIcons.clear, size: 18),
                        ),
                      );
                    },
                  ),
                ),
                if (hidden.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Hidden',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (final id in hidden)
                          ListTile(
                            title: Text(id.label),
                            trailing: TextButton(
                              onPressed: () => _toggle(id),
                              child: const Text('Add'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _widgets = [...DashboardLayout.defaults().widgets];
                    });
                  },
                  child: const Text('Reset to defaults'),
                ),
              ],
            ),
    );
  }
}
