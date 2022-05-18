import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/parts/reg_exp.part.dart';
import 'package:link_memo_holder/widgets/common/initial_kind_set.widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkAdd extends HookWidget {
  final ValueNotifier<List<String>> linkContentsState;
  final ValueNotifier<List<String>> linkKindsState;
  final ValueNotifier<UpdateCatch> updateLinkCatchState;
  final List<String> selectableLinkKinds;

  const LinkAdd({
    Key? key,
    required this.linkContentsState,
    required this.linkKindsState,
    required this.updateLinkCatchState,
    required this.selectableLinkKinds,
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
            Text(
              'URL',
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontSize: 14,
              ),
            ),
            SizedBox(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).tap_to_enter,
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                  ),
                ),
                controller: textController,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(
                    1000,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                InitialKindSet(
                  selectKindState: selectKindState,
                  selectableKinds: selectableLinkKinds,
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
                  onPressed: canUpdateState.value &&
                          textController.text.isNotEmpty
                      ? () async {
                          canUpdateState.value = false;
                          // URL判定
                          if (!regExp.hasMatch(textController.text)) {
                            EasyLoading.showToast(
                              AppLocalizations.of(context).invalid_url_format,
                              duration: const Duration(milliseconds: 2500),
                              toastPosition: EasyLoadingToastPosition.center,
                              dismissOnTap: false,
                            );
                          } else {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            // リンクを更新
                            linkContentsState.value.add(textController.text);
                            linkKindsState.value.add(selectKindState.value);

                            prefs.setStringList(
                                'linkContents', linkContentsState.value);
                            prefs.setStringList(
                                'linkKinds', linkKindsState.value);

                            updateLinkCatchState.value = UpdateCatch(
                              targetNumber: null,
                              isDelete: false,
                              kind: selectKindState.value,
                              linkData: textController.text,
                              isRegeneration: false,
                            );

                            EasyLoading.showToast(
                              AppLocalizations.of(context).added,
                              duration: const Duration(milliseconds: 2500),
                              toastPosition: EasyLoadingToastPosition.center,
                              dismissOnTap: false,
                            );

                            Navigator.pop(context);
                          }

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
