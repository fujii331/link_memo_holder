import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/services/fetch_ogp.service.dart';
import 'package:link_memo_holder/widgets/link_tab/link_card.widget.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

class LinkTab extends HookWidget {
  final ValueNotifier<List<Widget>> linkCardsState;
  final ValueNotifier<List<String>> linkContentsState;
  final ValueNotifier<List<String>> linkKindsState;
  final List<String> selectableLinkKinds;
  final ValueNotifier<bool> loadingState;
  final ValueNotifier<UpdateCatch> updateLinkCatchState;
  final ValueNotifier<String?> selectLinkKindState;

  const LinkTab({
    Key? key,
    required this.linkCardsState,
    required this.linkContentsState,
    required this.linkKindsState,
    required this.selectableLinkKinds,
    required this.loadingState,
    required this.updateLinkCatchState,
    required this.selectLinkKindState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isJapanese = Localizations.localeOf(context).toString() == 'ja';

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        List<Widget> linkCards = [];
        // loadingState.value = true;
        if (updateLinkCatchState.value.url != null) {
          final uri = Uri.parse(updateLinkCatchState.value.url!);
          Metadata? metadata = await fetchOgp(uri);
          linkCards.add(
            LinkCard(
              uri: uri,
              metadata: metadata,
              targetNumber: linkContentsState.value.length,
              isJapanese: isJapanese,
              selectableKinds: selectableLinkKinds,
              linkContentsState: linkContentsState,
              linkKindsState: linkKindsState,
              updateLinkCatchState: updateLinkCatchState,
            ),
          );
        } else {
          for (var i = 0; i < linkCardsState.value.length; i++) {
            Widget linkCard = linkCardsState.value[i];

            // 変更対象の場合
            if (i == updateLinkCatchState.value.targetNumber) {
              if (updateLinkCatchState.value.isDelete) {
                // 削除の場合何もしない
              } else {
                // 変更の場合は再作成
                final uri = Uri.parse(linkContentsState.value[i]);
                Metadata? metadata = await fetchOgp(uri);
                linkCards.add(
                  LinkCard(
                    uri: uri,
                    metadata: metadata,
                    targetNumber: i,
                    isJapanese: isJapanese,
                    selectableKinds: selectableLinkKinds,
                    linkContentsState: linkContentsState,
                    linkKindsState: linkKindsState,
                    updateLinkCatchState: updateLinkCatchState,
                  ),
                );
              }
            } else {
              // 対象じゃないものはそのまま追加
              linkCards.add(linkCard);
            }
          }
        }

        linkCardsState.value = linkCards;

        // loadingState.value = false;
      });
      return null;
    }, [updateLinkCatchState.value]);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/link_back.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: loadingState.value
          ? const Center(
              child: SpinKitThreeBounce(
                color: Color.fromARGB(255, 9, 178, 184),
                size: 30,
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
                top: 4,
                bottom: 10,
              ),
              child: linkCardsState.value.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        // 分類が設定されていないか、対象の分類だった場合は表示対象に
                        if (selectLinkKindState.value == null ||
                            linkKindsState.value[index] ==
                                selectLinkKindState.value) {
                          return linkCardsState.value[index];
                        } else {
                          return Container();
                        }
                      },
                      itemCount: linkCardsState.value.length,
                    )
                  : Text(
                      isJapanese ? 'リンクは未登録です' : "No links are registered.",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
            ),
    );
  }
}
