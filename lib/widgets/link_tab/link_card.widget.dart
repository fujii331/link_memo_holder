import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/data/split_word.dart';
import 'package:link_memo_holder/parts/reg_exp.part.dart';
import 'package:link_memo_holder/widgets/common/action_row.widget.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkCard extends HookWidget {
  final Uri uri;
  final Metadata? metadata;
  final ActionRow actionRow;
  final String linkData;

  const LinkCard({
    Key? key,
    required this.uri,
    required this.metadata,
    required this.actionRow,
    required this.linkData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataExist = metadata != null;
    final splitData = linkData.split(splitWord);
    final targetUrl = splitData[0];
    final title = dataExist
        ? metadata!.title ??
            (splitData.length > 1
                ? splitData[1]
                : AppLocalizations.of(context).no_title)
        : AppLocalizations.of(context).invalid_url;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
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
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () async {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  EasyLoading.showToast(
                    AppLocalizations.of(context).invalid_url,
                    duration: const Duration(milliseconds: 2500),
                    toastPosition: EasyLoadingToastPosition.center,
                    dismissOnTap: false,
                  );
                }
              },
              onLongPress: () async {
                final data = ClipboardData(text: targetUrl);
                await Clipboard.setData(data);

                EasyLoading.showToast(
                  AppLocalizations.of(context).url_copied,
                  duration: const Duration(milliseconds: 2500),
                  toastPosition: EasyLoadingToastPosition.center,
                  dismissOnTap: false,
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        height: 130,
                        child: dataExist &&
                                metadata!.image != null &&
                                regExp.hasMatch(metadata!.image!)
                            ? Image.network(metadata!.image!)
                            : const Image(
                                image: AssetImage('assets/images/no_image.png'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dataExist ? metadata!.description ?? targetUrl : '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade700,
              height: 1,
            ),
            actionRow,
          ],
        ),
      ),
    );
  }
}
