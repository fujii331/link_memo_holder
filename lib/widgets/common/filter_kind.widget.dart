import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/parts/kind_menu_item.part.dart';

class FilterKind extends HookWidget {
  final ValueNotifier<String?> selectKindState;
  final List<String> selectableKinds;
  final ValueNotifier<bool> loadingState;

  const FilterKind({
    Key? key,
    required this.selectKindState,
    required this.selectableKinds,
    required this.loadingState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool enabledFilter = selectableKinds.isNotEmpty;
    List<PopupMenuEntry<String>> kindMenus = [];
    final isJapanese = Localizations.localeOf(context).toString() == 'ja';

    for (String selectableKind in selectableKinds) {
      // 分類を追加
      kindMenus.add(
        kindMenuItem(
          selectKindState.value,
          selectableKind,
        ),
      );
    }

    return enabledFilter
        ? PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_alt,
              size: 26,
              color: enabledFilter ? Colors.white : Colors.grey.shade400,
            ),
            enabled: enabledFilter,
            onSelected: (String result) {
              selectKindState.value =
                  result != selectKindState.value ? result : null;
            },
            itemBuilder: (BuildContext context) => kindMenus,
          )
        : IconButton(
            iconSize: 26,
            icon: Icon(
              Icons.filter_alt,
              color: Colors.grey.shade400,
            ),
            onPressed: () {
              EasyLoading.showToast(
                isJapanese ? '分類を登録後に使用できます' : "Register kinds to use it.",
                duration: const Duration(milliseconds: 2500),
                toastPosition: EasyLoadingToastPosition.center,
                dismissOnTap: true,
              );
            },
          );
  }
}
