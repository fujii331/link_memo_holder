import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoDetailScreen extends HookWidget {
  final ValueNotifier<List<String>> memoContentsState;
  final ValueNotifier<UpdateCatch> updateMemoCatchState;
  final int targetNumber;

  const MemoDetailScreen({
    Key? key,
    required this.memoContentsState,
    required this.updateMemoCatchState,
    required this.targetNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final targetMemo = memoContentsState.value[targetNumber];
    final isEditingState = useState<bool>(false);
    final textController = useTextEditingController(text: targetMemo);
    final canUpdateState = useState<bool>(true);

    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditingState.value ? AppLocalizations.of(context).edit_mode : '',
        ),
        leading: TextButton(
          child: Icon(
            isEditingState.value ? Icons.close : Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: isEditingState.value
              ? () {
                  textController.text = targetMemo;
                  isEditingState.value = !isEditingState.value;
                }
              : () => Navigator.of(context).pop(),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        elevation: 0,
        backgroundColor: isEditingState.value
            ? Colors.brown.shade800.withOpacity(0.9)
            : Colors.brown.shade600.withOpacity(0.8),
        actions: <Widget>[
          IconButton(
            iconSize: 28,
            icon: isEditingState.value
                ? Icon(
                    Icons.check,
                    color: textController.text.isNotEmpty
                        ? Colors.green.shade300
                        : Colors.grey,
                  )
                : Icon(
                    Icons.edit,
                    color: Colors.green.shade300,
                  ),
            onPressed: !isEditingState.value
                ? () => isEditingState.value = !isEditingState.value
                : canUpdateState.value && textController.text.isNotEmpty
                    ? () async {
                        canUpdateState.value = false;
                        // 更新処理
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        memoContentsState.value[targetNumber] =
                            textController.text;
                        prefs.setStringList(
                            'memoContents', memoContentsState.value);

                        canUpdateState.value = true;

                        isEditingState.value = !isEditingState.value;

                        updateMemoCatchState.value = UpdateCatch(
                          targetNumber: null,
                          isDelete: !updateMemoCatchState.value.isDelete,
                          kind: null,
                          linkData: null,
                          isRegeneration: false,
                        );
                      }
                    : () {},
          ),
        ],
      ),
      body: isEditingState.value
          ? Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
              ),
              child: TextFormField(
                style: const TextStyle(
                  fontSize: 18,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: textController,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(
                    1000,
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                top: 12,
                right: 10,
                left: 10,
                bottom: 12,
              ),
              child: SingleChildScrollView(
                child: Text(
                  targetMemo,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
    );
  }
}
