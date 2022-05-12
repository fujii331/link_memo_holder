import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/parts/reg_exp.part.dart';
import 'package:shared_preferences/shared_preferences.dart';

void addSharedContent(
  String content,
  ValueNotifier<List<String>> memoContentsState,
  ValueNotifier<List<String>> linkContentsState,
  ValueNotifier<List<String>> memoKindsState,
  ValueNotifier<List<String>> linkKindsState,
  ValueNotifier<UpdateCatch> updateLinkCatchState,
  ValueNotifier<UpdateCatch> updateMemoCatchState,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // URL判定
  if (regExp.hasMatch(content)) {
    // urlが渡ってきた場合
    linkContentsState.value.add(content);
    linkKindsState.value.add('');
    prefs.setStringList('linkContents', linkContentsState.value);
    prefs.setStringList('linkKinds', linkKindsState.value);
    updateLinkCatchState.value = UpdateCatch(
      targetNumber: null,
      isDelete: false,
      kind: '',
      url: content,
      isRegeneration: false,
    );

    EasyLoading.showToast(
      "Link +",
      duration: const Duration(milliseconds: 2500),
      toastPosition: EasyLoadingToastPosition.center,
      dismissOnTap: false,
    );
  } else {
    // url以外の場合
    memoContentsState.value.add(content);
    memoKindsState.value.add('');
    prefs.setStringList('memoContents', memoContentsState.value);
    prefs.setStringList('memoKinds', memoKindsState.value);
    updateMemoCatchState.value = UpdateCatch(
      targetNumber: null,
      isDelete: !updateMemoCatchState.value.isDelete,
      kind: null,
      url: null,
      isRegeneration: false,
    );

    EasyLoading.showToast(
      "Memo +",
      duration: const Duration(milliseconds: 2500),
      toastPosition: EasyLoadingToastPosition.center,
      dismissOnTap: false,
    );
  }
}
