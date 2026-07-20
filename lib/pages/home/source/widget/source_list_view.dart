import 'package:flutter/material.dart';

import 'package:reader_nover/app/database/drift/app_database.dart' as db;
import 'package:reader_nover/app/service/source/source_check_policy.dart';

import '../../../common/app_empty_state.dart';
import '../logic.dart';
import 'source_card.dart';

class SourceListView extends StatelessWidget {
  const SourceListView({
    super.key,
    required this.logic,
  });

  final SourceLogic logic;

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    final sources = state.showSources;
    final hasFilter = state.searchKeyword.trim().isNotEmpty ||
        (state.groupFilter?.trim().isNotEmpty ?? false);

    if (sources.isEmpty) {
      return AppEmptyState(
        icon: hasFilter
            ? Icons.search_off_rounded
            : Icons.library_books_outlined,
        title: hasFilter ? '未找到匹配书源' : '还没有书源',
        subtitle: hasFilter
            ? '试试其他关键词，或清除分组筛选'
            : '导入书源后即可搜索与浏览书城',
        actions: [
          if (hasFilter) ...[
            if (state.searchKeyword.trim().isNotEmpty)
              OutlinedButton(
                onPressed: () => logic.searchSources(''),
                child: const Text('清空搜索'),
              ),
            if (state.groupFilter?.trim().isNotEmpty == true)
              OutlinedButton(
                onPressed: () => logic.filterByGroup(null),
                child: const Text('清除分组'),
              ),
          ] else
            FilledButton.tonalIcon(
              onPressed: logic.urlImport,
              icon: const Icon(Icons.link_rounded, size: 18),
              label: const Text('网址导入'),
            ),
        ],
      );
    }

    final sections = _buildSections(sources);
    final itemCount = sections.fold<int>(
      0,
      (count, section) => count + 1 + section.sources.length,
    );

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        state.isSelectionMode ? 16 : 88,
      ),
      itemCount: itemCount,
      itemBuilder: (_, index) {
        var cursor = 0;
        for (final section in sections) {
          if (index == cursor) {
            return _SourceGroupHeader(
              section: section,
              isActive: state.groupFilter == section.title,
              onTap: () {
                if (state.groupFilter == section.title) {
                  logic.filterByGroup(null);
                } else {
                  logic.filterByGroup(section.title);
                }
              },
            );
          }
          cursor++;
          final sourceIndex = index - cursor;
          if (sourceIndex >= 0 && sourceIndex < section.sources.length) {
            final source = section.sources[sourceIndex];
            return SourceCard(
              logic: logic,
              bookSource: source,
              onLongPress: () {
                if (!state.isSelectionMode) {
                  logic.toggleSelectionMode();
                  logic.toggleSelection(source.id);
                }
              },
            );
          }
          cursor += section.sources.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<_SourceSection> _buildSections(List<db.BookSource> sources) {
    final sectionMap = <String, List<db.BookSource>>{};

    for (final source in sources) {
      final groups = _parseGroups(source.bookSourceGroup);
      final invalidGroups = groups
          .where(SourceCheckPolicy.isInvalidGroup)
          .toList(growable: false);
      final effectiveGroup = invalidGroups.isNotEmpty
          ? invalidGroups.first
          : _primaryGroup(groups);

      sectionMap
          .putIfAbsent(effectiveGroup, () => <db.BookSource>[])
          .add(source);
    }

    return sectionMap.entries
        .map(
          (entry) => _SourceSection(
            title: entry.key,
            sources: entry.value,
            isInvalid: SourceCheckPolicy.isInvalidGroup(entry.key),
          ),
        )
        .toList()
      ..sort((a, b) {
        if (a.isInvalid != b.isInvalid) {
          return a.isInvalid ? -1 : 1;
        }
        if (a.title == '未分组') return 1;
        if (b.title == '未分组') return -1;
        return a.title.compareTo(b.title);
      });
  }

  List<String> _parseGroups(String? group) {
    if (group == null || group.trim().isEmpty) return const [];
    return group
        .split(RegExp(r'[,;，；]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  String _primaryGroup(List<String> groups) {
    if (groups.isEmpty) return '未分组';
    return groups.first;
  }
}

class _SourceSection {
  const _SourceSection({
    required this.title,
    required this.sources,
    required this.isInvalid,
  });

  final String title;
  final List<db.BookSource> sources;
  final bool isInvalid;
}

class _SourceGroupHeader extends StatelessWidget {
  const _SourceGroupHeader({
    required this.section,
    required this.isActive,
    required this.onTap,
  });

  final _SourceSection section;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = section.isInvalid
        ? colorScheme.error
        : isActive
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
      child: Material(
        color: isActive
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Icon(
                  section.isInvalid
                      ? Icons.error_outline_rounded
                      : isActive
                          ? Icons.folder_rounded
                          : Icons.folder_outlined,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${section.sources.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isActive
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_outlined,
                  size: 15,
                  color: color.withValues(alpha: 0.65),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
