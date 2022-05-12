import 'package:flutter/material.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/screens/main_tab.screen.dart';

void selectNotification(
  String payload,
  BuildContext context,
  ValueNotifier<List<String>> memoContentsState,
  ValueNotifier<List<String>> linkContentsState,
  ValueNotifier<List<String>> memoKindsState,
  ValueNotifier<List<String>> linkKindsState,
  ValueNotifier<UpdateCatch> updateLinkCatchState,
  ValueNotifier<UpdateCatch> updateMemoCatchState,
) async {
  debugPrint('notification payload: $payload');
  await Navigator.push(
    context,
    MaterialPageRoute<void>(
        builder: (context) => MainTabScreen(
              memoContentsState: memoContentsState,
              linkContentsState: linkContentsState,
              memoKindsState: memoKindsState,
              linkKindsState: linkKindsState,
              updateLinkCatchState: updateLinkCatchState,
              updateMemoCatchState: updateMemoCatchState,
            )),
  );
}
