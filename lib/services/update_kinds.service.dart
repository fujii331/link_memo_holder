import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void updateKinds(
  SharedPreferences prefs,
  bool isLinkTab,
  List<String> updatedSelectableKinds,
  List<String> updatedKinds,
  ValueNotifier<List<String>> selectableKindsState,
  ValueNotifier<List<String>> kindsState,
) async {
  // 分類を更新
  selectableKindsState.value = updatedSelectableKinds;
  kindsState.value = updatedKinds;
  if (isLinkTab) {
    prefs.setStringList('selectableLinkKinds', updatedSelectableKinds);
    prefs.setStringList('linkKinds', updatedKinds);
  } else {
    prefs.setStringList('selectableMemoKinds', updatedSelectableKinds);
    prefs.setStringList('memoKinds', updatedKinds);
  }
}
