import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/widgets/common/action_row.widget.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LinkCard extends HookWidget {
  final Uri uri;
  final Metadata? metadata;
  final ActionRow actionRow;

  const LinkCard({
    Key? key,
    required this.uri,
    required this.metadata,
    required this.actionRow,
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
              AppLocalizations.of(context).invalid_url,
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
                      ? metadata!.title ?? AppLocalizations.of(context).no_title
                      : AppLocalizations.of(context).invalid_url,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    height: 140,
                    child: dataExist && metadata!.image != null
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
                          AppLocalizations.of(context).no_description
                      : '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                Divider(color: Colors.grey.shade700),
                actionRow,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
