import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/database/drift/app_database.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/service/source/explore_screen.dart';
import '../../common/app_empty_state.dart';
import 'detail/view.dart';
import 'logic.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final TextEditingController _searchController = TextEditingController();

  StoreLogic get logic => Get.find<StoreLogic>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    logic.setSearchQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreLogic>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('书城'),
            actions: [
              IconButton(
                tooltip: '重新解析分类',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: logic.state.isLoading
                    ? null
                    : () => logic.loadSources(force: true),
              ),
              IconButton(
                tooltip: '搜索书籍',
                icon: const Icon(Icons.search_rounded),
                onPressed: () => Get.toNamed(AppRoutes.bookSearch),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                _buildSearchBar(context),
                Expanded(child: _buildSourceList(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          logic.setSearchQuery(value);
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: '筛选书源名称 / 分组',
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.38),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.filter_list_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.38),
            size: 20,
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: '清空',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _clearSearch,
                ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: colorScheme.onSurface.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSourceList(BuildContext context) {
    return GetBuilder<StoreLogic>(
      builder: (_) {
        final sources = logic.filteredSources;
        final hasQuery = logic.state.searchQuery.trim().isNotEmpty;

        if (sources.isEmpty && logic.state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (sources.isEmpty) {
          return AppEmptyState(
            icon: hasQuery
                ? Icons.search_off_rounded
                : Icons.storefront_outlined,
            title: hasQuery ? '未找到匹配书源' : '暂无可用书城',
            subtitle: hasQuery
                ? '试试其他关键词，或清空筛选'
                : '请先在「书源」页启用带发现规则的书源',
            actions: [
              if (hasQuery)
                OutlinedButton(
                  onPressed: _clearSearch,
                  child: const Text('清空筛选'),
                )
              else
                FilledButton.tonal(
                  onPressed: () => logic.loadSources(force: true),
                  child: const Text('重新加载'),
                ),
            ],
          );
        }

        final sections = _buildSections(sources);

        return RefreshIndicator(
          onRefresh: () => logic.loadSources(force: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return _StoreGroupSection(
                title: section.title,
                sources: section.sources,
                logic: logic,
              );
            },
          ),
        );
      },
    );
  }

  List<_StoreSection> _buildSections(List<BookSource> sources) {
    final map = <String, List<BookSource>>{};
    for (final source in sources) {
      final group = _primaryGroup(source.bookSourceGroup);
      map.putIfAbsent(group, () => <BookSource>[]).add(source);
    }
    final sections = map.entries
        .map((e) => _StoreSection(title: e.key, sources: e.value))
        .toList()
      ..sort((a, b) {
        if (a.title == '未分组') return 1;
        if (b.title == '未分组') return -1;
        return a.title.compareTo(b.title);
      });
    return sections;
  }

  String _primaryGroup(String? group) {
    if (group == null || group.trim().isEmpty) return '未分组';
    final parts = group
        .split(RegExp(r'[,;，；]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? '未分组' : parts.first;
  }
}

class _StoreSection {
  const _StoreSection({required this.title, required this.sources});

  final String title;
  final List<BookSource> sources;
}

class _StoreGroupSection extends StatelessWidget {
  const _StoreGroupSection({
    required this.title,
    required this.sources,
    required this.logic,
  });

  final String title;
  final List<BookSource> sources;
  final StoreLogic logic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 10, 2, 6),
          child: Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${sources.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...sources.map((source) {
          final isExpanded = logic.state.expandedSources[source.id] ?? false;
          final kinds = logic.state.sourceKinds[source.id] ?? [];
          final screenFields = logic.exploreScreenFieldsOf(source);
          final children = <Widget>[];
          if (isExpanded && screenFields.isNotEmpty) {
            children.add(
              _ExploreScreenFilters(
                source: source,
                fields: screenFields,
                logic: logic,
              ),
            );
          }
          if (isExpanded) {
            children.addAll(
              kinds.map(
                (kind) => _KindChip(
                  title: kind.title,
                  onTap: () {
                    Get.to(
                      () => StoreDetailPage(
                        source: source,
                        kind: kind,
                      ),
                    );
                  },
                ),
              ),
            );
          }
          return _SourceCard(
            sourceName: source.bookSourceName,
            sourceUrl: source.bookSourceUrl,
            kindCount: kinds.length,
            // 仅首次全量解析时显示小 loading，缓存命中后不再转圈
            isLoading: logic.state.isLoading &&
                !logic.state.hasLoaded &&
                !logic.state.sourceKinds.containsKey(source.id),
            isExpanded: isExpanded,
            onTap: () => logic.toggleSource(source.id),
            children: children,
          );
        }),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.sourceName,
    required this.sourceUrl,
    required this.kindCount,
    required this.isLoading,
    required this.isExpanded,
    required this.onTap,
    required this.children,
  });

  final String sourceName;
  final String sourceUrl;
  final int kindCount;
  final bool isLoading;
  final bool isExpanded;
  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = kindCount > 0
        ? colorScheme.primary
        : (isLoading ? colorScheme.tertiary : colorScheme.outline);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 4,
                      color: accent,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            _buildStatusIndicator(context, colorScheme),
                            const SizedBox(width: 10),
                            Expanded(child: _buildInfo(context)),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 12),
                child: children.isEmpty
                    ? Text(
                        isLoading ? '正在解析分类…' : '该源暂无可用发现分类',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final child in children)
                            if (child is _ExploreScreenFilters)
                              child
                            else
                              const SizedBox.shrink(),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final child in children)
                                if (child is! _ExploreScreenFilters) child,
                            ],
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.primary,
        ),
      );
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kindCount > 0 ? colorScheme.primary : colorScheme.outline,
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final host = _hostOf(sourceUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          sourceName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        if (host.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            host,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 6),
        _InfoPill(
          text: isLoading ? '解析中' : '$kindCount 个分类',
          icon: isLoading
              ? Icons.hourglass_top_rounded
              : Icons.widgets_outlined,
        ),
      ],
    );
  }

  String _hostOf(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || uri.host.isEmpty) return '';
      return uri.host;
    } catch (_) {
      return '';
    }
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              height: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.52),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreScreenFilters extends StatelessWidget {
  const _ExploreScreenFilters({
    required this.source,
    required this.fields,
    required this.logic,
  });

  final BookSource source;
  final List<ExploreScreenField> fields;
  final StoreLogic logic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '发现筛选',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          for (final field in fields) ...[
            Text(
              field.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
            ),
            const SizedBox(height: 4),
            if (field.options.isEmpty)
              Text(
                logic.exploreScreenValueOf(source, field.key),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: field.options.map((option) {
                  final selected =
                      logic.exploreScreenValueOf(source, field.key) == option;
                  return ChoiceChip(
                    label: Text(option, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) {
                      logic.setExploreScreenValue(
                        source: source,
                        key: field.key,
                        value: option,
                      );
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40, maxWidth: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
