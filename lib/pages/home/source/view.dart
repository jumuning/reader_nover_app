import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'check_result_detail_page.dart';
import 'logic.dart';
import 'state.dart';
import 'widget/source_check_config_dialog.dart';
import 'widget/source_check_progress_card.dart';
import 'widget/source_list_view.dart';
import 'widget/source_page_app_bar.dart';
import 'widget/source_page_dialogs.dart';
import 'widget/source_search_bar.dart';
import 'widget/source_selection_bar.dart';

class SourcePage extends StatelessWidget {
  const SourcePage({super.key});

  SourceLogic get logic => Get.find<SourceLogic>();
  SourceState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SourceLogic>(
      builder: (_) {
        return Scaffold(
          appBar: SourcePageAppBar(
            logic: logic,
            state: state,
            onShowSortDialog: () {
              showSourceSortDialog(
                logic: logic,
                selectedType: state.sortType,
              );
            },
            onShowCheckConfigDialog: () {
              showSourceCheckConfigDialog(context, logic);
            },
            onShowGroupManageDialog: () {
              showSourceGroupManageDialog(logic);
            },
          ),
          // 不用 nested bottomNavigationBar，避免被首页底栏挡住批量操作
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.deferToChild,
            child: Column(
              children: [
                if (state.isSearchBarVisible ||
                    state.searchKeyword.trim().isNotEmpty ||
                    (state.groupFilter?.trim().isNotEmpty ?? false))
                  SourceSearchBar(
                    value: state.searchKeyword,
                    groupFilter: state.groupFilter,
                    autofocus: state.isSearchBarVisible &&
                        state.searchKeyword.isEmpty &&
                        (state.groupFilter == null ||
                            state.groupFilter!.trim().isEmpty),
                    onChanged: logic.searchSources,
                    onClearGroupFilter: () => logic.filterByGroup(null),
                  ),
                SourceFilterSegment(
                  state: state,
                  onChanged: logic.changeShowType,
                ),
                if (state.isChecking || state.checkResults.isNotEmpty)
                  SourceCheckProgressCard(
                    state: state,
                    onOpenResults: () {
                      Get.to(() => const SourceCheckResultDetailPage());
                    },
                    onStopChecking: logic.stopChecking,
                  ),
                Expanded(child: SourceListView(logic: logic)),
                if (state.isSelectionMode)
                  SourceSelectionBar(
                    logic: logic,
                    state: state,
                    onShowSelectionAddGroupDialog: () {
                      showSourceSelectionGroupDialog(logic, isAdd: true);
                    },
                    onShowSelectionRemoveGroupDialog: () {
                      showSourceSelectionGroupDialog(logic, isAdd: false);
                    },
                    onShowDeleteDialog: () {
                      showSourceDeleteConfirmDialog(
                        logic: logic,
                        count: state.selectedIds.length,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
