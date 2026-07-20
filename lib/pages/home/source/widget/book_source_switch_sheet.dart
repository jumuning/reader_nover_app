import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reader_nover/app/service/book/models/source_book_info.dart';

class BookSourceSwitchSheet extends StatelessWidget {
  final String bookName;
  final String currentSourceName;
  final List<SourceBookInfo> sources;
  final ValueChanged<SourceBookInfo> onSelect;
  final bool isSearching;
  final String? currentSourceUrl;

  const BookSourceSwitchSheet({
    super.key,
    required this.bookName,
    required this.currentSourceName,
    required this.sources,
    required this.onSelect,
    this.isSearching = false,
    this.currentSourceUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildCurrentSource(),
          const Divider(height: 1),
          Expanded(child: _buildSourceList()),
        ],
      ),
    );
  }

  /// 顶部标题
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          const Text(
            '换源',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          if (isSearching)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          const Spacer(),
          Text(
            '找到 ${sources.length} 个源',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 当前书源
  Widget _buildCurrentSource() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(bookName),
        subtitle: currentSourceUrl != null
            ? Text(
                currentSourceUrl!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                currentSourceName,
                style: const TextStyle(fontSize: 12),
              ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '当前',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// 其他书源列表
  Widget _buildSourceList() {
    if (sources.isEmpty && !isSearching) {
      return const Center(child: Text('未找到其他可用书源'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: sources.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final source = sources[index];

        return ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: Text(source.bookSource.bookSourceName),
          subtitle: Text(
            source.lastChapter ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            Get.back();
            onSelect(source);
          },
        );
      },
    );
  }
}
