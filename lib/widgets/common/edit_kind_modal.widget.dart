import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    List<Widget> editRows = [];

    final canAdd = selectableKindsState.value.length <= 10;

    // 分類が9個以下の場合、登録用の列を追加
    editRows.add(
      SizedBox(
        width: 190,
        child: Text(
          AppLocalizations.of(context).add,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: canAdd ? Colors.orange.shade500 : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
    editRows.add(_addRow(
      canDoAction,
      context,
      selectableKindsState.value.length <= 10,
    ));

    if (selectableKindsState.value.isNotEmpty) {
      editRows.add(
        SizedBox(
          width: 190,
          child: Text(
            AppLocalizations.of(context).edit_delete,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.green.shade400,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    for (String selectableKind in selectableKindsState.value) {
      // 分類を追加
      editRows.add(
        _editRow(
          selectableKind,
          canDoAction,
          context,
        ),
      );
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
                ? AppLocalizations.of(context).link_kinds
                : AppLocalizations.of(context).memo_kinds,
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
    BuildContext context,
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
              hintText: AppLocalizations.of(context).tap_to_enter,
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
                        AppLocalizations.of(context).cannot_enter_same_kind,
                        duration: const Duration(milliseconds: 2500),
                        toastPosition: EasyLoadingToastPosition.center,
                        dismissOnTap: true,
                      );
                    }
                  }
                  updateCatchState.value = UpdateCatch(
                    targetNumber: null,
                    isDelete: !updateCatchState.value.isDelete,
                    kind: null,
                    url: null,
                    isRegeneration: true,
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
    BuildContext context,
    bool canAdd,
  ) {
    final textController = useTextEditingController(text: '');
    final validateOkState =
        useState(canDoAction.value && textController.text != '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 35,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: canAdd
                    ? AppLocalizations.of(context).tap_to_enter
                    : AppLocalizations.of(context).cannot_add,
              ),
              style: const TextStyle(
                fontSize: 14,
              ),
              enabled: canAdd,
              controller: textController,
              onChanged: (target) {
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
                      if (selectableKind == textController.text) {
                        existSameKind = true;
                        break;
                      }
                    }

                    // 同じ分類が存在しなかった場合
                    if (!existSameKind) {
                      // 分類を追加
                      selectableKindsState.value.add(textController.text);

                      if (isLinkTab) {
                        prefs.setStringList(
                            'selectableLinkKinds', selectableKindsState.value);
                      } else {
                        prefs.setStringList(
                            'selectableMemoKinds', selectableKindsState.value);
                      }

                      textController.text = '';
                    } else {
                      EasyLoading.showToast(
                        AppLocalizations.of(context).cannot_enter_same_kind,
                        duration: const Duration(milliseconds: 2500),
                        toastPosition: EasyLoadingToastPosition.center,
                        dismissOnTap: true,
                      );
                    }

                    updateCatchState.value = UpdateCatch(
                      targetNumber: null,
                      isDelete: !updateCatchState.value.isDelete,
                      kind: null,
                      url: null,
                      isRegeneration: true,
                    );

                    validateOkState.value = false;
                    canDoAction.value = true;
                  }
                : () {},
          ),
        ],
      ),
    );
  }
}
