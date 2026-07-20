import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/theme/app_theme_palette.dart';
import 'package:reader_nover/pages/home/setting/logic.dart';
import 'package:reader_nover/pages/home/setting/state.dart';
import 'package:reader_nover/pages/reading_stats/view.dart';
import 'package:reader_nover/app/l10n/generated/l10n.dart';
import 'package:reader_nover/util/gap.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({
    super.key,
    required this.logic,
  });

  final SettingLogic logic;

  SettingState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).setting),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          GetBuilder<SettingLogic>(builder: (logic) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '外观',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '明暗模式',
                      style: context.theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode, size: 18),
                          label: Text('浅色'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.settings_suggest, size: 18),
                          label: Text('系统'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode, size: 18),
                          label: Text('深色'),
                        ),
                      ],
                      selected: {state.themeMode},
                      onSelectionChanged: (set) {
                        if (set.isEmpty) return;
                        logic.changeThemeMode(set.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).language,
                      style: context.theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'system',
                          label: Text(S.of(context).languageSystem),
                        ),
                        ButtonSegment(
                          value: 'zh',
                          label: Text(S.of(context).languageChinese),
                        ),
                        ButtonSegment(
                          value: 'en',
                          label: Text(S.of(context).languageEnglish),
                        ),
                      ],
                      selected: {state.localeCode},
                      onSelectionChanged: (selection) {
                        if (selection.isNotEmpty) {
                          logic.changeLocale(selection.first);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '主题配色',
                      style: context.theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '经典白为优化前的偏白风格，墨绿为当前默认配色',
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...AppThemePalette.values.map((palette) {
                      final selected = state.themePalette == palette;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: selected
                              ? context.theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.45)
                              : context
                                  .theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => logic.changeThemePalette(palette),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  _PaletteSwatch(palette: palette),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          palette.label,
                                          style: context
                                              .theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          palette.description,
                                          style: context
                                              .theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: context
                                                .theme.colorScheme.onSurface
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: context.theme.colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
          const Gap.vs(),
          GetBuilder<SettingLogic>(builder: (logic) {
            return ElevatedButton(
              onPressed: state.isCheckingLocalBookStorage
                  ? null
                  : logic.checkLocalBookStorage,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.of(context).localStorageCheck),
                          const SizedBox(height: 4),
                          Text(
                            S.of(context).localStorageCheckSubtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.isCheckingLocalBookStorage)
                      const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.storage_outlined),
                  ],
                ),
              ),
            );
          }),
          const Gap.vs(),
          ElevatedButton(
            onPressed: () => Get.to(() => const ReadingStatsPage()),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).readingStats),
                      const SizedBox(height: 4),
                      Text(
                        S.of(context).readingStatsSubtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.insights_outlined),
                ],
              ),
            ),
          ),
          const Gap.vs(),
          ElevatedButton(
            onPressed: () {
              logic.reloadThemeAsset();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(S.of(context).reloadTheme),
                  const Spacer(),
                  const Icon(Icons.refresh),
                ],
              ),
            ),
          ),
          const Gap.vs(),
          GetBuilder<SettingLogic>(builder: (logic) {
            return SwitchListTile(
              title: const Text('允许不安全 HTTPS 证书'),
              subtitle: const Text(
                '默认关闭。开启后会接受自签名或无效证书，仅建议在少数兼容性场景下使用。',
                style: TextStyle(fontSize: 12),
              ),
              value: state.allowInsecureCertificates,
              onChanged: logic.changeAllowInsecureCertificates,
            );
          }),
        ],
      ),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({required this.palette});

  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final colors = switch (palette) {
      AppThemePalette.classicWhite => const [
          Color(0xFFFFFFFF),
          Color(0xFFF2F2F2),
          Color(0xFF1976D2),
        ],
      AppThemePalette.money => const [
          Color(0xFFE8F5E9),
          Color(0xFF2E7D32),
          Color(0xFF1B5E20),
        ],
    };

    return SizedBox(
      width: 40,
      height: 28,
      child: Row(
        children: colors
            .map(
              (c) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: c,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
