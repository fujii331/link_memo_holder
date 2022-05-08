import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/widgets/common/action_row.widget.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkCard extends HookWidget {
  final Uri uri;
  final Metadata? metadata;
  final int targetNumber;
  final bool isJapanese;
  final List<String> selectableKinds;
  final ValueNotifier<List<String>> linkContentsState;
  final ValueNotifier<List<String>> linkKindsState;
  final ValueNotifier<UpdateCatch> updateLinkCatchState;

  const LinkCard({
    Key? key,
    required this.uri,
    required this.metadata,
    required this.targetNumber,
    required this.isJapanese,
    required this.selectableKinds,
    required this.linkContentsState,
    required this.linkKindsState,
    required this.updateLinkCatchState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool dataExist = metadata != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () async {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            EasyLoading.showToast(
              isJapanese
                  ? '登録されたURLを開けませんでした'
                  : "Can't open the registered URL.",
              duration: const Duration(milliseconds: 2500),
              toastPosition: EasyLoadingToastPosition.center,
              dismissOnTap: true,
            );
          }
        },
        child: Card(
          color: Colors.blueGrey.shade50,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dataExist
                      ? metadata!.title ?? (isJapanese ? 'タイトルなし' : "No title")
                      : isJapanese
                          ? 'URLが無効です'
                          : 'Url is invalid.',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    height: 145,
                    child: dataExist
                        ? Image.network(metadata!.image!)
                        : const Image(
                            image: AssetImage('assets/images/no_image.png'),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  dataExist
                      ? metadata!.description ??
                          (isJapanese ? '説明文なし' : "No description")
                      : '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                Divider(color: Colors.grey.shade700),
                ActionRow(
                  selectableKinds: selectableKinds,
                  contentsState: linkContentsState,
                  kindsState: linkKindsState,
                  targetNumber: targetNumber,
                  updateCatchState: updateLinkCatchState,
                  isLinkTab: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
