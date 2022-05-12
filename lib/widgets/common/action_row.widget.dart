import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:link_memo_holder/widgets/common/delete_modal.widget.dart';
import 'package:link_memo_holder/widgets/common/timer_set_modal.widget.dart';

import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/widgets/common/set_kind.widget.dart';

class ActionRow extends HookWidget {
  final List<String> selectableKinds;
  final ValueNotifier<List<String>> contentsState;
  final ValueNotifier<List<String>> kindsState;
  final int targetNumber;
  final ValueNotifier<UpdateCatch> updateCatchState;
  final bool isLinkTab;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const ActionRow({
    Key? key,
    required this.selectableKinds,
    required this.contentsState,
    required this.kindsState,
    required this.targetNumber,
    required this.updateCatchState,
    required this.isLinkTab,
    required this.flutterLocalNotificationsPlugin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final linkKind = kindsState.value[targetNumber];

    return Container(
      height: 29,
      padding: const EdgeInsets.only(
        top: 3,
        left: 10,
        right: 15,
        bottom: 6,
      ),
      child: Row(
        children: [
          Text(
            linkKind != '' ? linkKind : AppLocalizations.of(context).no_kind,
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
            isLinkTab: isLinkTab,
          ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.all(0),
            iconSize: 22,
            icon: Icon(
              Icons.timer,
              color: Colors.orange.shade500,
            ),
            onPressed: () async {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.NO_HEADER,
                headerAnimationLoop: false,
                showCloseIcon: true,
                animType: AnimType.SCALE,
                width:
                    MediaQuery.of(context).size.width * .86 > 550 ? 550 : null,
                body: TimerSetModal(
                  isLinkTab: isLinkTab,
                  content: contentsState.value[targetNumber],
                  flutterLocalNotificationsPlugin:
                      flutterLocalNotificationsPlugin,
                ),
              ).show();
            },
          ),
          const SizedBox(width: 5),
          // 削除ボタン
          GestureDetector(
            onTap: () async {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.NO_HEADER,
                headerAnimationLoop: false,
                showCloseIcon: true,
                animType: AnimType.SCALE,
                width:
                    MediaQuery.of(context).size.width * .86 > 550 ? 550 : null,
                body: DeleteModal(
                  contentsState: contentsState,
                  kindsState: kindsState,
                  targetNumber: targetNumber,
                  updateCatchState: updateCatchState,
                  isLinkTab: isLinkTab,
                  content: contentsState.value[targetNumber],
                ),
              ).show();
            },
            child: Icon(
              Icons.delete,
              color: Colors.red.shade400,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
