import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:link_memo_holder/data/split_word.dart';
import 'package:link_memo_holder/services/add_shared_content.service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:link_memo_holder/models/link_card_item.model.dart';
import 'package:link_memo_holder/models/update_catch.model.dart';
import 'package:link_memo_holder/services/fetch_ogp.service.dart';
import 'package:link_memo_holder/widgets/common/action_row.widget.dart';
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
  final String? sharedText;

  const MainTabScreen({
    Key? key,
    required this.sharedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memoContentsState = useState<List<String>>([]);
    final linkContentsState = useState<List<String>>([]);
    final memoKindsState = useState<List<String>>([]);
    final linkKindsState = useState<List<String>>([]);
    final updateLinkCatchState = useState<UpdateCatch>(
      const UpdateCatch(
        targetNumber: null,
        isDelete: false,
        kind: null,
        linkData: null,
        isRegeneration: false,
      ),
    );
    final updateMemoCatchState = useState<UpdateCatch>(
      const UpdateCatch(
        targetNumber: null,
        isDelete: false,
        kind: null,
        linkData: null,
        isRegeneration: false,
      ),
    );

    final screenNo = useState<int>(0);
    final pageController = usePageController(initialPage: 0, keepPage: true);
    final selectLinkKindState = useState<String?>(null);
    final selectMemoKindState = useState<String?>(null);
    final isLink = screenNo.value == 0;

    final selectableLinkKindsState = useState<List<String>>([]);
    final selectableMemoKindsState = useState<List<String>>([]);

    final loadingState = useState<bool>(true);
    final linkCardItemsState = useState<List<LinkCardItem>>([]);

    final initialState = useState<bool>(true);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        if (initialState.value) {
          // 通知、タイムゾーンを初期化
          const AndroidInitializationSettings initializationSettingsAndroid =
              AndroidInitializationSettings('app_icon');
          const InitializationSettings initializationSettings =
              InitializationSettings(android: initializationSettingsAndroid);
          await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
          );

          final String currentTimeZone =
              await FlutterNativeTimezone.getLocalTimezone();
          tz.initializeTimeZones();
          tz.setLocalLocation(tz.getLocation(currentTimeZone));

          // データ初期化
          SharedPreferences prefs = await SharedPreferences.getInstance();

          selectableLinkKindsState.value =
              prefs.getStringList('selectableLinkKinds') ?? [];

          selectableMemoKindsState.value =
              prefs.getStringList('selectableMemoKinds') ?? [];

          linkContentsState.value = prefs.getStringList('linkContents') ?? [];
          // linkContentsState.value = [];

          memoContentsState.value = prefs.getStringList('memoContents') ?? [];

          linkKindsState.value = prefs.getStringList('linkKinds') ?? [];
          // linkKindsState.value = [];

          memoKindsState.value = prefs.getStringList('memoKinds') ?? [];

          loadingState.value = true;
          List<LinkCardItem> linkCardItems = [];

          for (var i = 0; i < linkContentsState.value.length; i++) {
            final linkData = linkContentsState.value[i];
            final splitData = linkData.split(splitWord);
            final targetUrl = splitData[0];
            final uri = Uri.parse(targetUrl);
            final Metadata? metadata = await fetchOgp(uri);

            final titleExist = metadata != null && metadata.title == null;

            linkCardItems.add(
              LinkCardItem(
                linkCard: LinkCard(
                  uri: uri,
                  metadata: metadata,
                  actionRow: ActionRow(
                    selectableKinds: selectableLinkKindsState.value,
                    contentsState: linkContentsState,
                    kindsState: linkKindsState,
                    targetNumber: i,
                    updateCatchState: updateLinkCatchState,
                    isLinkTab: true,
                    flutterLocalNotificationsPlugin:
                        flutterLocalNotificationsPlugin,
                    linkTitleEditable: titleExist,
                  ),
                  linkData: linkData,
                ),
                uri: uri,
                metadata: metadata,
                linkData: linkData,
              ),
            );
          }

          linkCardItemsState.value = linkCardItems;
          loadingState.value = false;

          initialState.value = false;
        }

        if (sharedText != null) {
          addSharedContent(
            sharedText!,
            memoContentsState,
            linkContentsState,
            memoKindsState,
            linkKindsState,
            updateLinkCatchState,
            updateMemoCatchState,
          );
        }
      });
      return null;
    }, [sharedText]);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      resizeToAvoidBottomInset: false,
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
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
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
        shape: CircleBorder(
          side: BorderSide(
            width: 1,
            color: isLink ? Colors.teal.shade600 : Colors.deepOrange.shade900,
          ),
        ),
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
        backgroundColor:
            isLink ? Colors.teal.shade400 : Colors.deepOrange.shade800,
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
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          screenNo.value = index;
        },
        children: [
          LinkTab(
            linkCardItemsState: linkCardItemsState,
            linkContentsState: linkContentsState,
            linkKindsState: linkKindsState,
            selectableLinkKinds: selectableLinkKindsState.value,
            loadingState: loadingState,
            updateLinkCatchState: updateLinkCatchState,
            selectLinkKind: selectLinkKindState.value,
            flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          ),
          MemoTab(
            selectableMemoKindsState: selectableMemoKindsState,
            memoContentsState: memoContentsState,
            memoKindsState: memoKindsState,
            updateMemoCatchState: updateMemoCatchState,
            selectMemoKind: selectMemoKindState.value,
            flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          ),
        ],
      ),
    );
  }
}
