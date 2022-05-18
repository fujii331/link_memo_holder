import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:link_memo_holder/data/advertising.dart';

import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/screens/memo_detail.screen.dart';
import 'package:link_memo_holder/widgets/common/action_row.widget.dart';

class MemoTab extends HookWidget {
  final ValueNotifier<List<String>> selectableMemoKindsState;
  final ValueNotifier<List<String>> memoContentsState;
  final ValueNotifier<List<String>> memoKindsState;
  final ValueNotifier<UpdateCatch> updateMemoCatchState;
  final String? selectMemoKind;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const MemoTab({
    Key? key,
    required this.selectableMemoKindsState,
    required this.memoContentsState,
    required this.memoKindsState,
    required this.updateMemoCatchState,
    required this.selectMemoKind,
    required this.flutterLocalNotificationsPlugin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memoCardsState = useState<List<Widget>>([]);
    final double paddingWidth = MediaQuery.of(context).size.width > 550.0
        ? (MediaQuery.of(context).size.width - 550) / 2
        : 10;

    final BannerAd myBanner = BannerAd(
      adUnitId: androidBannerAdvid,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

    myBanner.load();

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        List<Widget> memoCards = [];
        for (var i = 0; i < memoContentsState.value.length; i++) {
          memoCards.add(
            _memoCard(
              memoContentsState.value[i],
              memoKindsState.value[i],
              i,
              context,
              updateMemoCatchState,
            ),
          );
        }

        memoCardsState.value = memoCards;
      });
      return null;
    }, [
      updateMemoCatchState.value,
    ]);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/memo_back.png'),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Padding(
          padding: EdgeInsets.only(
            left: paddingWidth,
            right: paddingWidth,
            top: 8,
            bottom: 5,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                  bottom: 7,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: AdWidget(ad: myBanner),
                  width: myBanner.size.width.toDouble(),
                  height: myBanner.size.height.toDouble(),
                ),
              ),
              memoCardsState.value.isNotEmpty &&
                      (selectMemoKind == null ||
                          memoKindsState.value
                              .where((element) => element == selectMemoKind)
                              .toList()
                              .isNotEmpty)
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height - 230,
                      // height: MediaQuery.of(context).size.height - 165,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final displayIndex =
                              memoCardsState.value.length - index - 1;

                          // 分類が設定されていないか、対象の分類だった場合は表示対象に
                          if (selectMemoKind == null ||
                              memoKindsState.value[displayIndex] ==
                                  selectMemoKind) {
                            return memoCardsState.value[displayIndex];
                          } else {
                            return Container();
                          }
                        },
                        itemCount: memoCardsState.value.length,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context).no_memo,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
            ],
          )),
    );
  }

  Widget _memoCard(
    String memo,
    String memoKind,
    int targetNumber,
    BuildContext context,
    ValueNotifier<UpdateCatch> updateMemoCatchState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: Colors.brown.shade50,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemoDetailScreen(
                      memoContentsState: memoContentsState,
                      targetNumber: targetNumber,
                      updateMemoCatchState: updateMemoCatchState,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 15,
                  bottom: 10,
                ),
                width: double.infinity,
                child: Text(
                  memo,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade700,
              height: 1,
            ),
            ActionRow(
              selectableKinds: selectableMemoKindsState.value,
              contentsState: memoContentsState,
              kindsState: memoKindsState,
              targetNumber: targetNumber,
              updateCatchState: updateMemoCatchState,
              isLinkTab: false,
              flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
              linkTitleEditable: false,
            ),
          ],
        ),
      ),
    );
  }
}
