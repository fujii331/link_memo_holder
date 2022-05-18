import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:link_memo_holder/data/split_word.dart';

import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkTitleEditModal extends HookWidget {
  final ValueNotifier<List<String>> linkContentsState;
  final int targetNumber;
  final ValueNotifier<UpdateCatch> updateLinkCatchState;

  const LinkTitleEditModal({
    Key? key,
    required this.linkContentsState,
    required this.targetNumber,
    required this.updateLinkCatchState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final targetContent = linkContentsState.value[targetNumber];
    final splitData = targetContent.split(splitWord);
    final targetUrl = splitData[0];
    final targetTitle = splitData.length > 1 ? splitData[1] : '';
    final textController = useTextEditingController(text: targetTitle);
    final canUpdateState = useState<bool>(targetTitle != '');

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 15,
        right: 15,
        bottom: 25,
      ),
      child: Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).link_title_edit,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 200,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).tap_to_enter,
                hintStyle: const TextStyle(
                  color: Colors.black38,
                ),
              ),
              controller: textController,
              onChanged: (target) {
                canUpdateState.value = target != '';
              },
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(
                  30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).update),
            style: ElevatedButton.styleFrom(
              primary: canUpdateState.value
                  ? Colors.orange.shade600
                  : Colors.orange.shade200,
              shape: const StadiumBorder(),
              side: BorderSide(
                width: 2,
                color: Colors.orange.shade700,
              ),
            ),
            onPressed: canUpdateState.value
                ? () async {
                    canUpdateState.value = false;

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    final updateData =
                        targetUrl + splitWord + textController.text;

                    // リンクを更新
                    linkContentsState.value[targetNumber] = updateData;

                    prefs.setStringList(
                        'linkContents', linkContentsState.value);

                    updateLinkCatchState.value = UpdateCatch(
                      targetNumber: targetNumber,
                      isDelete: false,
                      kind: null,
                      linkData: updateData,
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
