import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
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

    final isJapanese = Localizations.localeOf(context).toString() == 'ja';
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
                  hintText: isJapanese ? 'タップして入力' : 'Tap to enter',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                  ),
                ),
                controller: textController,
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
                  child: const Text('登録'),
                  style: ElevatedButton.styleFrom(
                    primary: textController.text.isNotEmpty
                        ? Colors.orange.shade600
                        : Colors.orange.shade200,
                    padding: EdgeInsets.only(
                      bottom: Platform.isAndroid ? 3 : 1,
                    ),
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
                          // 正規表現
                          RegExp regExp = RegExp(
                              r'((https?:\/\/)|(https?:www\.)|(www\.))[a-zA-Z0-9-]{1,256}\.[a-zA-Z0-9]{2,6}(\/[a-zA-Z0-9亜-熙ぁ-んァ-ヶ()@:%_\+.~#?&\/=-]*)?');

                          // URL判定
                          if (!regExp.hasMatch(textController.text)) {
                            EasyLoading.showToast(
                              isJapanese
                                  ? 'URLの形式が不正です'
                                  : "URL format is invalid.",
                              duration: const Duration(milliseconds: 2500),
                              toastPosition: EasyLoadingToastPosition.center,
                              dismissOnTap: true,
                            );
                          } else {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            // リンクを更新
                            linkContentsState.value
                                .insert(0, textController.text);
                            linkKindsState.value
                                .insert(0, selectKindState.value);

                            prefs.setStringList(
                                'linkContents', linkContentsState.value);
                            prefs.setStringList(
                                'linkKinds', linkKindsState.value);

                            updateLinkCatchState.value = UpdateCatch(
                              targetNumber: 0,
                              isDelete: false,
                              kind: selectKindState.value,
                              url: textController.text,
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
