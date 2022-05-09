import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/parts/kind_menu_item.part.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetKind extends HookWidget {
  final List<String> selectableKinds;
  final ValueNotifier<List<String>> kindsState;
  final int targetNumber;
  final ValueNotifier<UpdateCatch> updateCatchState;

  final bool isLinkTab;

  const SetKind({
    Key? key,
    required this.selectableKinds,
    required this.kindsState,
    required this.targetNumber,
    required this.updateCatchState,
    required this.isLinkTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool enabledSet = selectableKinds.isNotEmpty;
    List<PopupMenuEntry<String>> kindMenus = [];

    for (String selectableKind in selectableKinds) {
      // 分類を追加
      kindMenus.add(
        kindMenuItem(
          kindsState.value[targetNumber],
          selectableKind,
        ),
      );
    }

    return SizedBox(
      height: 20,
      child: PopupMenuButton<String>(
        padding: const EdgeInsets.all(0),
        icon: Icon(
          Icons.edit,
          color: enabledSet ? Colors.green.shade400 : Colors.grey,
        ),
        iconSize: 22,
        enabled: enabledSet,
        onSelected: (String result) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          kindsState.value[targetNumber] = result;
          prefs.setStringList(
              isLinkTab ? 'linkKinds' : 'memoKinds', kindsState.value);

          updateCatchState.value = UpdateCatch(
            targetNumber: targetNumber,
            isDelete: false,
            kind: result,
            url: null,
            isRegeneration: false,
          );
        },
        itemBuilder: (BuildContext context) => kindMenus,
      ),
    );
  }
}
