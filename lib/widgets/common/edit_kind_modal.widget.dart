import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/services/update_kinds.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditKindModal extends HookWidget {
  final BuildContext screenContext;
  final ValueNotifier<List<String>> selectableKindsState;
  final ValueNotifier<String?> selectKindState;
  final ValueNotifier<List<String>> kindsState;
  final ValueNotifier<UpdateCatch> updateCatchState;
  final bool isLinkTab;

  const EditKindModal({
    Key? key,
    required this.screenContext,
    required this.selectableKindsState,
    required this.selectKindState,
    required this.kindsState,
    required this.updateCatchState,
    required this.isLinkTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canDoAction = useState(true);
    final isJapanese = Localizations.localeOf(context).toString() == 'ja';

    List<Widget> editRows = [];

    for (String selectableKind in selectableKindsState.value) {
      // 分類を追加
      editRows.add(
        _editRow(
          selectableKind,
          canDoAction,
          isJapanese,
        ),
      );
    }

    // 分類が15個以下の場合、登録用の列を追加
    if (selectableKindsState.value.length <= 15) {
      editRows.add(_addRow(
        canDoAction,
        isJapanese,
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 25,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLinkTab
                ? (isJapanese ? 'リンク分類' : "Link kinds")
                : isJapanese
                    ? 'メモ分類'
                    : "Memo kinds",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: editRows,
          ),
        ],
      ),
    );
  }

  Widget _editRow(
    String targetKind,
    ValueNotifier<bool> canDoAction,
    bool isJapanese,
  ) {
    final textState = useState(targetKind);
    final validateOkState =
        useState(canDoAction.value && textState.value != targetKind);
    final isDeleteState = useState(textState.value == '');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 35,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: isJapanese ? '更新で削除' : 'You can delete.',
            ),
            style: const TextStyle(
              fontSize: 14,
            ),
            initialValue: targetKind,
            onChanged: (target) {
              textState.value = target;
              validateOkState.value = textState.value != targetKind;
              isDeleteState.value = textState.value == '';
            },
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(
                10,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        // 更新ボタン
        IconButton(
          icon: Icon(
            isDeleteState.value ? Icons.delete : Icons.check,
            color: isDeleteState.value
                ? Colors.red
                : validateOkState.value
                    ? Colors.green
                    : Colors.grey,
          ),
          onPressed: validateOkState.value
              ? () async {
                  // 処理が終わるまで更新できないようにする
                  canDoAction.value = false;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  if (isDeleteState.value) {
                    // 削除処理の場合
                    selectableKindsState.value.remove(targetKind);

                    // 削除後分類を作成する
                    final deletedKinds = kindsState.value.map((String kind) {
                      if (kind == targetKind) {
                        return '';
                      } else {
                        return kind;
                      }
                    }).toList();

                    // 選択中の分類を削除した場合
                    if (selectKindState.value == targetKind) {
                      selectKindState.value = null;
                    }

                    updateKinds(
                      prefs,
                      isLinkTab,
                      selectableKindsState.value,
                      deletedKinds,
                      selectableKindsState,
                      kindsState,
                    );

                    Navigator.pop(screenContext);

                    AwesomeDialog(
                      context: screenContext,
                      dialogType: DialogType.NO_HEADER,
                      headerAnimationLoop: false,
                      showCloseIcon: true,
                      animType: AnimType.SCALE,
                      width: MediaQuery.of(screenContext).size.width * .86 > 550
                          ? 550
                          : null,
                      body: EditKindModal(
                        screenContext: screenContext,
                        selectableKindsState: selectableKindsState,
                        selectKindState: selectKindState,
                        kindsState: kindsState,
                        updateCatchState: updateCatchState,
                        isLinkTab: isLinkTab,
                      ),
                    ).show();
                  } else {
                    // 更新処理の場合
                    // 他の分類と同じ値がないか判定用
                    bool existSameKind = false;

                    // 更新後選択可能分類を作成する
                    // ついでに同じ値の分類がないか判定
                    final updatedSelectableKinds =
                        selectableKindsState.value.map((String kind) {
                      if (kind == textState.value) {
                        existSameKind = true;
                      }

                      if (kind == targetKind) {
                        return textState.value;
                      } else {
                        return kind;
                      }
                    }).toList();

                    // 同じ分類が存在しなかった場合
                    if (!existSameKind) {
                      // 登録済コンテンツの分類を更新
                      final updatedKinds = kindsState.value.map((String kind) {
                        if (kind == targetKind) {
                          return textState.value;
                        } else {
                          return kind;
                        }
                      }).toList();

                      updateKinds(
                        prefs,
                        isLinkTab,
                        updatedSelectableKinds,
                        updatedKinds,
                        selectableKindsState,
                        kindsState,
                      );

                      // 選択中の分類を変更した場合
                      if (selectKindState.value == targetKind) {
                        selectKindState.value = textState.value;
                      }
                    } else {
                      EasyLoading.showToast(
                        isJapanese
                            ? '同じ名前の分類は登録できません'
                            : "You can't enter the same kind.",
                        duration: const Duration(milliseconds: 2500),
                        toastPosition: EasyLoadingToastPosition.center,
                        dismissOnTap: true,
                      );
                    }
                  }
                  updateCatchState.value = UpdateCatch(
                    targetNumber: 0,
                    isDelete: !updateCatchState.value.isDelete,
                    kind: null,
                    url: null,
                  );
                  validateOkState.value = false;
                  canDoAction.value = true;
                }
              : () {},
        ),
      ],
    );
  }

  Widget _addRow(
    ValueNotifier<bool> canDoAction,
    bool isJapanese,
  ) {
    final textState = useState('');
    final validateOkState =
        useState(canDoAction.value && textState.value != '');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 35,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: isJapanese ? 'タップして入力' : 'Tap to enter.',
            ),
            style: const TextStyle(
              fontSize: 14,
            ),
            onChanged: (target) {
              textState.value = target;
              validateOkState.value = target.isNotEmpty;
            },
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(
                10,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        // 登録ボタン
        IconButton(
          icon: Icon(
            Icons.add,
            color: validateOkState.value ? Colors.green : Colors.grey,
          ),
          onPressed: validateOkState.value
              ? () async {
                  // 処理が終わるまで更新できないようにする
                  canDoAction.value = false;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  // 他の分類と同じ値がないか判定用
                  bool existSameKind = false;

                  // 同じ値の分類がないか判定
                  for (String selectableKind in selectableKindsState.value) {
                    if (selectableKind == textState.value) {
                      existSameKind = true;
                      break;
                    }
                  }

                  // 同じ分類が存在しなかった場合
                  if (!existSameKind) {
                    // 分類を追加
                    selectableKindsState.value.add(textState.value);

                    if (isLinkTab) {
                      prefs.setStringList(
                          'selectableLinkKinds', selectableKindsState.value);
                    } else {
                      prefs.setStringList(
                          'selectableMemoKinds', selectableKindsState.value);
                    }
                  } else {
                    EasyLoading.showToast(
                      isJapanese
                          ? '同じ名前の分類は登録できません'
                          : "You can't enter the same kind.",
                      duration: const Duration(milliseconds: 2500),
                      toastPosition: EasyLoadingToastPosition.center,
                      dismissOnTap: true,
                    );
                  }

                  updateCatchState.value = UpdateCatch(
                    targetNumber: 0,
                    isDelete: !updateCatchState.value.isDelete,
                    kind: null,
                    url: null,
                  );

                  validateOkState.value = false;
                  canDoAction.value = true;
                }
              : () {},
        ),
      ],
    );
  }
}
