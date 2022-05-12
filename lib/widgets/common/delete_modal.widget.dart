import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteModal extends HookWidget {
  final ValueNotifier<List<String>> contentsState;
  final ValueNotifier<List<String>> kindsState;
  final int targetNumber;
  final ValueNotifier<UpdateCatch> updateCatchState;
  final String content;
  final bool isLinkTab;

  const DeleteModal({
    Key? key,
    required this.contentsState,
    required this.kindsState,
    required this.targetNumber,
    required this.updateCatchState,
    required this.content,
    required this.isLinkTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canUpdateState = useState<bool>(true);

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).confirm_delete,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: Text(
              isLinkTab ? 'URL' : AppLocalizations.of(context).memo,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            height: isLinkTab ? 52 : 120,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(
                  5,
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).delete),
            style: ElevatedButton.styleFrom(
              primary: Colors.red.shade600,
              shape: const StadiumBorder(),
              side: BorderSide(
                width: 2,
                color: Colors.red.shade700,
              ),
            ),
            onPressed: canUpdateState.value
                ? () async {
                    canUpdateState.value = false;
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    // 対象を削除
                    contentsState.value.removeAt(targetNumber);
                    kindsState.value.removeAt(targetNumber);

                    prefs.setStringList(
                        isLinkTab ? 'linkContents' : 'memoContents',
                        contentsState.value);
                    prefs.setStringList(isLinkTab ? 'linkKinds' : 'memoKinds',
                        kindsState.value);

                    EasyLoading.showToast(
                      AppLocalizations.of(context).delete_finished,
                      duration: const Duration(milliseconds: 3000),
                      toastPosition: EasyLoadingToastPosition.center,
                      dismissOnTap: false,
                    );

                    updateCatchState.value = UpdateCatch(
                      targetNumber: targetNumber,
                      isDelete: true,
                      kind: null,
                      url: null,
                      isRegeneration: false,
                    );

                    Navigator.pop(context);

                    canUpdateState.value = true;
                  }
                : () {},
          ),
        ],
      ),
    );
  }
}
