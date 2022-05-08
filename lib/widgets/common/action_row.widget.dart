import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/widgets/common/set_kind.widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActionRow extends HookWidget {
  final List<String> selectableKinds;
  final ValueNotifier<List<String>> contentsState;
  final ValueNotifier<List<String>> kindsState;
  final int targetNumber;
  final ValueNotifier<UpdateCatch> updateCatchState;
  final bool isLinkTab;

  const ActionRow({
    Key? key,
    required this.selectableKinds,
    required this.contentsState,
    required this.kindsState,
    required this.targetNumber,
    required this.updateCatchState,
    required this.isLinkTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isJapanese = Localizations.localeOf(context).toString() == 'ja';
    final linkKind = kindsState.value[targetNumber];

    return Row(
      children: [
        Text(
          linkKind != '' ? linkKind : (isJapanese ? '分類なし' : "No kind"),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
        SetKind(
          selectableKinds: selectableKinds,
          kindsState: kindsState,
          targetNumber: targetNumber,
          updateCatchState: updateCatchState,
          isLinkTab: true,
        ),
        const Spacer(),
        // 削除ボタン
        GestureDetector(
          onTap: () async {
            EasyLoading.showToast(
              isJapanese ? 'ボタン長押しで削除' : "Press and hold the button to delete.",
              duration: const Duration(milliseconds: 2500),
              toastPosition: EasyLoadingToastPosition.center,
              dismissOnTap: true,
            );
          },
          onLongPress: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            // 対象を削除
            contentsState.value.removeAt(targetNumber);
            kindsState.value.removeAt(targetNumber);

            prefs.setStringList(isLinkTab ? 'linkContents' : 'memoContents',
                contentsState.value);
            prefs.setStringList(
                isLinkTab ? 'linkKinds' : 'memoKinds', kindsState.value);

            EasyLoading.showToast(
              isJapanese ? '削除しました' : "Deleted it.",
              duration: const Duration(milliseconds: 3000),
              toastPosition: EasyLoadingToastPosition.center,
              dismissOnTap: true,
            );

            updateCatchState.value = UpdateCatch(
              targetNumber: targetNumber,
              isDelete: true,
              kind: null,
              url: null,
            );
          },
          child: Icon(
            Icons.delete,
            color: Colors.red.shade400,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
