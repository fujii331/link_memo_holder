import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/screens/memo_detail.screen.dart';
import 'package:link_memo_holder/widgets/common/action_row.widget.dart';

class MemoTab extends HookWidget {
  final ValueNotifier<List<String>> selectableMemoKindsState;
  final ValueNotifier<List<String>> memoContentsState;
  final ValueNotifier<List<String>> memoKindsState;
  final ValueNotifier<UpdateCatch> updateMemoCatchState;
  final String? selectMemoKind;

  const MemoTab({
    Key? key,
    required this.selectableMemoKindsState,
    required this.memoContentsState,
    required this.memoKindsState,
    required this.updateMemoCatchState,
    required this.selectMemoKind,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isJapanese = Localizations.localeOf(context).toString() == 'ja';
    final memoCardsState = useState<List<Widget>>([]);

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        List<Widget> memoCards = [];
        for (var i = 0; i < memoContentsState.value.length; i++) {
          memoCards.add(
            _memoCard(
              memoContentsState.value[i],
              memoKindsState.value[i],
              i,
              isJapanese,
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
        padding: const EdgeInsets.only(
          right: 10,
          left: 10,
          top: 4,
          bottom: 10,
        ),
        child: memoCardsState.value.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  // 分類が設定されていないか、対象の分類だった場合は表示対象に
                  if (selectMemoKind == null ||
                      memoKindsState.value[index] == selectMemoKind) {
                    return memoCardsState.value[index];
                  } else {
                    return Container();
                  }
                },
                itemCount: memoCardsState.value.length,
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

  Widget _memoCard(
    String memo,
    String memoKind,
    int targetNumber,
    bool isJapanese,
    BuildContext context,
    ValueNotifier<UpdateCatch> updateMemoCatchState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
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
                SizedBox(
                  height: 30,
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
                Divider(color: Colors.grey.shade700),
                ActionRow(
                  selectableKinds: selectableMemoKindsState.value,
                  contentsState: memoContentsState,
                  kindsState: memoKindsState,
                  targetNumber: targetNumber,
                  updateCatchState: updateMemoCatchState,
                  isLinkTab: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
