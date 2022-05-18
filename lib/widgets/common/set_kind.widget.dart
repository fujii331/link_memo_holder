import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/parts/kind_menu_item.part.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final displayKind = kindsState.value[targetNumber];
    final double kindWidth = MediaQuery.of(context).size.width > 550.0
        ? 350
        : MediaQuery.of(context).size.width - 180;

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
      width: kindWidth,
      child: PopupMenuButton<String>(
        padding: const EdgeInsets.all(0),
        icon: SizedBox(
          width: double.infinity,
          child: Text(
            displayKind != ''
                ? displayKind
                : AppLocalizations.of(context).no_kind,
            style: TextStyle(
              fontSize: 13,
              color: enabledSet ? Colors.green.shade800 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.start,
          ),
        ),
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
            linkData: null,
            isRegeneration: false,
          );
        },
        itemBuilder: (BuildContext context) => kindMenus,
      ),
    );
  }
}
