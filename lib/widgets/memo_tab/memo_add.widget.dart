import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/widgets/common/initial_kind_set.widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MemoAdd extends HookWidget {
  final ValueNotifier<List<String>> memoContentsState;
  final ValueNotifier<List<String>> memoKindsState;
  final ValueNotifier<UpdateCatch> updateMemoCatchState;
  final List<String> selectableMemoKinds;

  const MemoAdd({
    Key? key,
    required this.memoContentsState,
    required this.memoKindsState,
    required this.updateMemoCatchState,
    required this.selectableMemoKinds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double paddingWidth = MediaQuery.of(context).size.width > 450.0
        ? (MediaQuery.of(context).size.width - 450) / 2
        : 25;

    final textController = useTextEditingController();
    final selectKindState = useState<String>('');

    final canUpdateState = useState<bool>(true);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 25,
          left: paddingWidth,
          right: paddingWidth,
          bottom: 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              child: Text(
                AppLocalizations.of(context).memo,
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade500,
                  width: 1.5,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).tap_to_enter,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(
                      1000,
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                  controller: textController,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                InitialKindSet(
                  selectKindState: selectKindState,
                  selectableKinds: selectableMemoKinds,
                ),
                const Spacer(),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context).add_data),
                  style: ElevatedButton.styleFrom(
                    primary: textController.text.isNotEmpty
                        ? Colors.orange.shade600
                        : Colors.orange.shade200,
                    shape: const StadiumBorder(),
                    side: BorderSide(
                      width: 2,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  onPressed:
                      canUpdateState.value && textController.text.isNotEmpty
                          ? () async {
                              canUpdateState.value = false;
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              // メモを更新
                              memoContentsState.value.add(textController.text);
                              memoKindsState.value.add(selectKindState.value);

                              updateMemoCatchState.value = UpdateCatch(
                                targetNumber: null,
                                isDelete: !updateMemoCatchState.value.isDelete,
                                kind: null,
                                linkData: null,
                                isRegeneration: false,
                              );

                              prefs.setStringList(
                                  'memoContents', memoContentsState.value);
                              prefs.setStringList(
                                  'memoKinds', memoKindsState.value);

                              EasyLoading.showToast(
                                AppLocalizations.of(context).added,
                                duration: const Duration(milliseconds: 2500),
                                toastPosition: EasyLoadingToastPosition.center,
                                dismissOnTap: false,
                              );

                              Navigator.pop(context);

                              canUpdateState.value = true;
                            }
                          : () {},
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
