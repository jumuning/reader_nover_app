import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/database/drift/app_database.dart' as db;
import 'form_schema.dart';
import 'logic.dart';
import 'state.dart';

/// 书源编辑页面
class BookSourceEditPage extends StatelessWidget {
  final db.BookSource source;
  final Future<void> Function(db.BookSource source)? onOpenSourceLogin;

  const BookSourceEditPage({
    super.key,
    required this.source,
    this.onOpenSourceLogin,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookSourceEditLogic>(
      init: BookSourceEditLogic(
        onOpenSourceLogin: onOpenSourceLogin,
      )..initSource(source),
      builder: (logic) {
        final state = logic.state;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: ValueListenableBuilder<TextEditingValue>(
                valueListenable:
                    logic.controllerFor(BookSourceEditFieldKey.sourceName),
                builder: (_, value, __) {
                  final titleText = value.text.trim();
                  return Text(
                    titleText.isEmpty ? source.bookSourceName : titleText,
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.login),
                  tooltip: '登录',
                  onPressed: logic.loginCurrentSource,
                ),
                IconButton(
                  icon: Icon(
                    state.isTesting ? Icons.hourglass_top : Icons.play_arrow,
                  ),
                  tooltip: state.isTesting ? '测试中' : '测试',
                  onPressed: state.isTesting ? null : logic.testSource,
                ),
                if (state.isSaving)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: '保存',
                    onPressed: logic.saveSource,
                  ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: '编辑'),
                  Tab(text: '测试'),
                ],
              ),
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _EditFormTab(logic: logic),
                      _TestTab(logic: logic),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// 编辑表单 Tab
class _EditFormTab extends StatelessWidget {
  final BookSourceEditLogic logic;

  const _EditFormTab({required this.logic});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...bookSourceEditSections.map(_buildSection),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSection(BookSourceEditSectionSchema section) {
    return _buildGroup(
      title: section.title,
      icon: section.icon,
      initiallyExpanded: section.initiallyExpanded,
      children: [
        ...section.fields.map(_buildFieldTile),
        if (section.showEnabledSwitch)
          GetBuilder<BookSourceEditLogic>(
            builder: (_) => SwitchListTile(
              title: const Text('启用搜索'),
              value: logic.state.enabled,
              onChanged: logic.toggleEnabled,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (section.showEnabledSwitch)
          GetBuilder<BookSourceEditLogic>(
            builder: (_) => SwitchListTile(
              title: const Text('启用发现'),
              value: logic.state.enabledExplore,
              onChanged: logic.toggleEnabledExplore,
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }

  Widget _buildFieldTile(BookSourceEditFieldSchema field) {
    return _buildTextField(
      field.label,
      logic.controllerFor(field.key),
      required: field.required,
    );
  }

  Widget _buildGroup({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
  }) {
    final bool isEmpty = controller.text.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditDialog(label, controller, required),
          borderRadius: BorderRadius.circular(10),
          splashColor: Get.theme.colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: Get.theme.colorScheme.primary.withValues(alpha: 0.04),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isEmpty
                    ? Colors.grey.withValues(alpha: 0.35)
                    : Get.theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// label
                RichText(
                  text: TextSpan(
                    text: label,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Get.theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                    children: [
                      if (required)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                /// content / placeholder
                Text(
                  isEmpty ? '点击编辑' : controller.text,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: isEmpty
                        ? Colors.grey.withValues(alpha: 0.6)
                        : Get.theme.colorScheme.primary.withValues(alpha: 0.9),
                    fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    String label,
    TextEditingController controller,
    bool required,
  ) {
    final tempController = TextEditingController(text: controller.text);
    final charCount = ValueNotifier<int>(controller.text.length);

    tempController.addListener(() {
      charCount.value = tempController.text.length;
    });

    Get.dialog(
      Builder(builder: (context) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题栏
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          required ? '$label *' : label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            size: 20, color: Colors.grey[600]),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                // 工具栏
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.15)),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildToolButton(
                        icon: Icons.content_paste,
                        tooltip: '粘贴',
                        onTap: () async {
                          final data =
                              await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            final selection = tempController.selection;
                            final text = tempController.text;
                            final newText = text.replaceRange(
                              selection.start,
                              selection.end,
                              data!.text!,
                            );
                            tempController.text = newText;
                            tempController.selection = TextSelection.collapsed(
                              offset: selection.start + data.text!.length,
                            );
                            Get.showSnackbar(const GetSnackBar(
                              message: '已粘贴',
                              duration: Duration(seconds: 1),
                            ));
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildToolButton(
                        icon: Icons.content_copy,
                        tooltip: '复制全部',
                        onTap: () {
                          if (tempController.text.isNotEmpty) {
                            Clipboard.setData(
                                ClipboardData(text: tempController.text));
                            Get.showSnackbar(const GetSnackBar(
                              message: '已复制到剪贴板',
                              duration: Duration(seconds: 1),
                            ));
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildToolButton(
                        icon: Icons.clear_all,
                        tooltip: '清空',
                        onTap: () {
                          if (tempController.text.isNotEmpty) {
                            tempController.clear();
                          }
                        },
                      ),
                      const Spacer(),
                      // 字符统计
                      ValueListenableBuilder<int>(
                        valueListenable: charCount,
                        builder: (_, count, __) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count 字符',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 内容区
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: TextField(
                      controller: tempController,
                      maxLines: null,
                      expands: true,
                      autofocus: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.5),
                        ),
                        hintText: '请输入内容...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        contentPadding: const EdgeInsets.all(14),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.03),
                      ),
                    ),
                  ),
                ),
                // 底部按钮
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          controller.text = tempController.text;
                          logic.update();
                          Get.back();
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
      ),
    );
  }
}

/// 测试 Tab
class _TestTab extends StatelessWidget {
  final BookSourceEditLogic logic;

  const _TestTab({required this.logic});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookSourceEditLogic>(
      builder: (_) {
        final state = logic.state;

        return Column(
          children: [
            _buildHeader(state),
            const Divider(height: 1),
            Expanded(child: _buildResultList(state)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BookSourceEditState state) {
    final hasResults = state.testResults.isNotEmpty;
    final successCount =
        state.testResults.where((r) => r.status == TestStatus.success).length;
    final errorCount =
        state.testResults.where((r) => r.status == TestStatus.error).length;
    final warningCount =
        state.testResults.where((r) => r.status == TestStatus.warning).length;

    return ListTile(
      leading: Icon(
        state.isTesting
            ? Icons.hourglass_top
            : (hasResults ? Icons.check_circle : Icons.bug_report),
        color: state.isTesting
            ? Colors.orange
            : (errorCount > 0 ? Colors.red : Colors.green),
      ),
      title: Text(state.isTesting ? '正在测试...' : (hasResults ? '测试完成' : '测试结果')),
      subtitle: hasResults
          ? Text(
              '成功: $successCount  警告: $warningCount  失败: $errorCount',
              style: const TextStyle(fontSize: 12),
            )
          : const Text(
              '点击右上角 ▶ 开始测试',
              style: TextStyle(fontSize: 12),
            ),
      trailing: hasResults
          ? Chip(
              label: Text(errorCount > 0 ? '有问题' : '正常'),
              backgroundColor: (errorCount > 0 ? Colors.red : Colors.green)
                  .withValues(alpha: 0.2),
            )
          : Chip(
              label: const Text('未测试'),
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
            ),
    );
  }

  Widget _buildResultList(BookSourceEditState state) {
    if (state.testResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science,
                size: 64, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('点击测试按钮开始验证书源', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.testResults.length,
      itemBuilder: (_, i) {
        final result = state.testResults[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _buildStatusIcon(result.status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(result.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          if (result.elapsed != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${result.elapsed}ms',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.message,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (result.detail != null &&
                          result.detail!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          result.detail!,
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(TestStatus status) {
    switch (status) {
      case TestStatus.testing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case TestStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TestStatus.warning:
        return const Icon(Icons.warning, color: Colors.orange);
      case TestStatus.error:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
