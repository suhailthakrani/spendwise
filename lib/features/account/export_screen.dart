import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/export_format.dart';
import '../../data/models/export_preview.dart';
import '../../data/models/export_range.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key, required this.format});

  final ExportFormat format;

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportRangePreset _preset = ExportRangePreset.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;
  ExportPreview? _preview;
  Object? _previewError;
  bool _loadingPreview = false;
  bool _exporting = false;

  ExportDateRange get _range => ExportDateRange(
        preset: _preset,
        start: _customStart,
        end: _customEnd,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPreview());
  }

  Future<void> _refreshPreview() async {
    if (_preset == ExportRangePreset.custom &&
        (_customStart == null || _customEnd == null)) {
      setState(() {
        _preview = null;
        _previewError = null;
        _loadingPreview = false;
      });
      return;
    }

    setState(() {
      _loadingPreview = true;
      _previewError = null;
    });

    try {
      final currency = ref.read(currencyDisplayProvider);
      final preview = await ref.read(exportServiceProvider).preview(
            range: _range,
            currency: currency,
          );
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _loadingPreview = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _previewError = e;
        _preview = null;
        _loadingPreview = false;
      });
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: DateTime(now.year, now.month, now.day),
            ),
    );
    if (picked == null) return;
    setState(() {
      _preset = ExportRangePreset.custom;
      _customStart = picked.start;
      _customEnd = picked.end;
    });
    await _refreshPreview();
  }

  Future<void> _export() async {
    if (_preview == null || _preview!.isEmpty || _exporting) return;

    setState(() => _exporting = true);
    try {
      final currency = ref.read(currencyDisplayProvider);
      final result = await ref.read(exportServiceProvider).exportAndShare(
            format: widget.format,
            range: _range,
            currency: currency,
          );
      if (!mounted) return;
      if (result.status == ShareResultStatus.dismissed) {
        // User cancelled share sheet — not an error.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.format.label} export ready'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyDisplayProvider);
    final icon = widget.format == ExportFormat.csv
        ? AppIcons.exportCsv
        : AppIcons.exportExcel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Export ${widget.format.label}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          8,
          AppSpacing.page,
          AppSpacing.navClearance,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AppIconBox(
                    asset: icon,
                    color: AppColors.primary,
                    size: 48,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a timeline',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Preview expenses before exporting',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in ExportRangePreset.values)
                ChoiceChip(
                  label: Text(preset.label),
                  selected: _preset == preset,
                  onSelected: (_) async {
                    if (preset == ExportRangePreset.custom) {
                      await _pickCustomRange();
                      return;
                    }
                    setState(() => _preset = preset);
                    await _refreshPreview();
                  },
                ),
            ],
          ),
          if (_preset == ExportRangePreset.custom &&
              _customStart != null &&
              _customEnd != null) ...[
            const SizedBox(height: 8),
            Text(
              _range.displayLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Preview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (_loadingPreview)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_previewError != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Could not load preview: $_previewError'),
              ),
            )
          else if (_preset == ExportRangePreset.custom &&
              (_customStart == null || _customEnd == null))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Pick a custom date range to preview.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ),
            )
          else if (_preview != null)
            _PreviewCard(preview: _preview!, currencyCode: currency.displayCurrencyCode)
          else
            const SizedBox.shrink(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: (_preview == null ||
                    _preview!.isEmpty ||
                    _loadingPreview ||
                    _exporting)
                ? null
                : _export,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : AppIcon(
                    icon,
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            label: Text(
              _exporting
                  ? 'Preparing…'
                  : 'Export ${_preview?.rowCount ?? 0} expenses',
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends ConsumerWidget {
  const _PreviewCard({
    required this.preview,
    required this.currencyCode,
  });

  final ExportPreview preview;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyDisplayProvider);
    final dateFmt = DateFormat('MMM d, yyyy');

    if (preview.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const AppIcon(AppIcons.receiptEmpty, size: 36),
              const SizedBox(height: 12),
              Text(
                'No expenses in this range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try a wider timeline.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${preview.rowCount} expenses · ${preview.rangeLabel}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  currency.formatAlreadyConverted(preview.totalDisplay),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Amounts in $currencyCode',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.tertiaryText(context),
              ),
            ),
            if (preview.categoryTotals.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Top categories',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText(context),
                ),
              ),
              const SizedBox(height: 8),
              ...preview.categoryTotals.entries.take(5).map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text(
                        currency.formatAlreadyConverted(e.value),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 12),
            Divider(color: AppColors.border(context)),
            const SizedBox(height: 8),
            Text(
              'Sample rows',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            ...preview.sampleRows.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 88,
                      child: Text(
                        dateFmt.format(row.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.note.isEmpty ? row.categoryName : row.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currency.formatAlreadyConverted(row.amountDisplay),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (preview.rowCount > preview.sampleRows.length)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${preview.rowCount - preview.sampleRows.length} more in file',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.tertiaryText(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
