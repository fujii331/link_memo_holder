import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/services/fetch_ogp.service.dart';
import 'package:link_memo_holder/widgets/common/edit_kind_modal.widget.dart';
import 'package:link_memo_holder/widgets/common/filter_kind.widget.dart';
import 'package:link_memo_holder/widgets/link_tab.widget.dart';
import 'package:link_memo_holder/widgets/link_tab/link_add.widget.dart';
import 'package:link_memo_holder/widgets/link_tab/link_card.widget.dart';
import 'package:link_memo_holder/widgets/memo_tab.widget.dart';
import 'package:link_memo_holder/widgets/memo_tab/memo_add.widget.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainTabScreen extends HookWidget {
  final ValueNotifier<List<String>> memoContentsState;
  final ValueNotifier<List<String>> linkContentsState;
  final ValueNotifier<List<String>> memoKindsState;
  final ValueNotifier<List<String>> linkKindsState;

  const MainTabScreen({
    Key? key,
    required this.memoContentsState,
    required this.linkContentsState,
    required this.memoKindsState,
    required this.linkKindsState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isJapanese = Localizations.localeOf(context).toString() == 'ja';
    final screenNo = useState<int>(0);
    final pageController = usePageController(initialPage: 0, keepPage: true);
    final selectLinkKindState = useState<String?>(null);
    final selectMemoKindState = useState<String?>(null);
    final isLink = screenNo.value == 0;

    final selectableLinkKindsState = useState<List<String>>([]);
    final selectableMemoKindsState = useState<List<String>>([]);

    final loadingState = useState<bool>(true);
    final linkCardsState = useState<List<Widget>>([]);

    final updateLinkCatchState = useState<UpdateCatch>(
      const UpdateCatch(
        targetNumber: 0,
        isDelete: false,
        kind: null,
        url: null,
      ),
    );

    final updateMemoCatchState = useState<UpdateCatch>(
      const UpdateCatch(
        targetNumber: 0,
        isDelete: false,
        kind: null,
        url: null,
      ),
    );

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        // 初回起動時のみ通過
        SharedPreferences prefs = await SharedPreferences.getInstance();

        selectableLinkKindsState.value =
            prefs.getStringList('selectableLinkKinds') ?? [];

        selectableMemoKindsState.value =
            prefs.getStringList('selectableMemoKinds') ?? [];

        linkContentsState.value = prefs.getStringList('linkContents') ?? [];

        memoContentsState.value = prefs.getStringList('memoContents') ?? [];

        linkKindsState.value = prefs.getStringList('linkKinds') ?? [];

        memoKindsState.value = prefs.getStringList('memoKinds') ?? [];

        loadingState.value = true;
        List<Widget> linkCards = [];

        for (var i = 0; i < linkContentsState.value.length; i++) {
          final uri = Uri.parse(linkContentsState.value[i]);

          Metadata? metadata = await fetchOgp(uri);
          // 分類を追加
          linkCards.add(
            LinkCard(
              uri: uri,
              metadata: metadata,
              targetNumber: i,
              isJapanese: isJapanese,
              selectableKinds: selectableLinkKindsState.value,
              linkContentsState: linkContentsState,
              linkKindsState: linkKindsState,
              updateLinkCatchState: updateLinkCatchState,
            ),
          );
        }

        linkCardsState.value = linkCards;
        loadingState.value = false;
      });
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            (isLink ? selectLinkKindState.value : selectMemoKindState.value) ??
                'All',
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        elevation: 0,
        backgroundColor: isLink
            ? Colors.blueGrey.shade600.withOpacity(0.8)
            : Colors.brown.shade600.withOpacity(0.8),
        actions: [
          FilterKind(
            selectKindState: isLink ? selectLinkKindState : selectMemoKindState,
            selectableKinds: isLink
                ? selectableLinkKindsState.value
                : selectableMemoKindsState.value,
            loadingState: loadingState,
          ),
          IconButton(
            iconSize: 26,
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.NO_HEADER,
                headerAnimationLoop: false,
                showCloseIcon: true,
                animType: AnimType.SCALE,
                width:
                    MediaQuery.of(context).size.width * .86 > 550 ? 550 : null,
                body: isLink
                    ? EditKindModal(
                        screenContext: context,
                        selectableKindsState: selectableLinkKindsState,
                        selectKindState: selectLinkKindState,
                        kindsState: linkKindsState,
                        updateCatchState: updateLinkCatchState,
                        isLinkTab: true,
                      )
                    : EditKindModal(
                        screenContext: context,
                        selectableKindsState: selectableMemoKindsState,
                        selectKindState: selectMemoKindState,
                        kindsState: memoKindsState,
                        updateCatchState: updateMemoCatchState,
                        isLinkTab: false,
                      ),
              ).show();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: isLink
                    ? LinkAdd(
                        linkContentsState: linkContentsState,
                        linkKindsState: linkKindsState,
                        updateLinkCatchState: updateLinkCatchState,
                        selectableLinkKinds: selectableLinkKindsState.value,
                      )
                    : MemoAdd(
                        memoContentsState: memoContentsState,
                        memoKindsState: memoKindsState,
                        updateMemoCatchState: updateMemoCatchState,
                        selectableMemoKinds: selectableMemoKindsState.value,
                      ),
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
        backgroundColor: isLink
            ? const Color.fromARGB(255, 9, 178, 184)
            : Colors.orange.shade800,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        activeIndex: screenNo.value,
        itemCount: 2,
        gapLocation: GapLocation.center,
        backgroundColor: isLink
            ? Colors.blueGrey.shade600.withOpacity(0.85)
            : Colors.brown.shade600.withOpacity(0.85),
        tabBuilder: (int index, bool isActive) {
          final color =
              isActive ? Colors.yellow.shade500 : Colors.grey.shade200;
          final isLinkTab = index == 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLinkTab ? Icons.web : Icons.note,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  isLinkTab ? 'Link' : 'Memo',
                  style: TextStyle(color: color),
                ),
              )
            ],
          );
        },
        onTap: (index) {
          screenNo.value = index;
          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: PageView(
          controller: pageController,
          onPageChanged: (index) {
            screenNo.value = index;
          },
          children: [
            LinkTab(
              linkCardsState: linkCardsState,
              linkContentsState: linkContentsState,
              linkKindsState: linkKindsState,
              selectableLinkKinds: selectableLinkKindsState.value,
              loadingState: loadingState,
              updateLinkCatchState: updateLinkCatchState,
              selectLinkKindState: selectLinkKindState,
            ),
            MemoTab(
              selectableMemoKindsState: selectableMemoKindsState,
              memoContentsState: memoContentsState,
              memoKindsState: memoKindsState,
              updateMemoCatchState: updateMemoCatchState,
              selectMemoKind: selectMemoKindState.value,
            ),
          ],
        ),
      ),
    );
  }
}
