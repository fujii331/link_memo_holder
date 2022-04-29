import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/screens/main_tab.screen.dart';
import 'package:link_memo_holder/services/add_shared_content.service.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();

  runApp(const MyApp());
}

useWidgetLifecycleObserver(
  ValueNotifier<List<String>> memoContentListState,
  ValueNotifier<List<String>> linkContentListState,
  ValueNotifier<List<String>> memoKindListState,
  ValueNotifier<List<String>> linkKindListState,
) {
  return use(_WidgetObserver(
    memoContentListState,
    linkContentListState,
    memoKindListState,
    linkKindListState,
  ));
}

class _WidgetObserver extends Hook<void> {
  final ValueNotifier<List<String>> memoContentListState;
  final ValueNotifier<List<String>> linkContentListState;
  final ValueNotifier<List<String>> memoKindListState;
  final ValueNotifier<List<String>> linkKindListState;

  const _WidgetObserver(
    this.memoContentListState,
    this.linkContentListState,
    this.memoKindListState,
    this.linkKindListState,
  );

  @override
  HookState<void, Hook<void>> createState() {
    return _WidgetObserverState(
      memoContentListState,
      linkContentListState,
      memoKindListState,
      linkKindListState,
    );
  }
}

class _WidgetObserverState extends HookState<void, _WidgetObserver>
    with WidgetsBindingObserver {
  final ValueNotifier<List<String>> memoContentListState;
  final ValueNotifier<List<String>> linkContentListState;
  final ValueNotifier<List<String>> memoKindListState;
  final ValueNotifier<List<String>> linkKindListState;

  _WidgetObserverState(
    this.memoContentListState,
    this.linkContentListState,
    this.memoKindListState,
    this.linkKindListState,
  );

  late StreamSubscription _intentDataStreamSubscription;

  @override
  void build(BuildContext context) {}

  @override
  void initHook() {
    super.initHook();

    // アプリ起動中の共有
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) async {
      addSharedContent(
        value,
        memoContentListState,
        linkContentListState,
        memoKindListState,
        linkKindListState,
      );
    }, onError: (err) {
      print("共有に失敗しました error: $err");
    });

    // アプリ停止中の共有
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value != null) {
        addSharedContent(
          value,
          memoContentListState,
          linkContentListState,
          memoKindListState,
          linkKindListState,
        );
      }
    });

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}

class MyApp extends HookWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memoContentListState = useState<List<String>>([]);
    final linkContentListState = useState<List<String>>([]);
    final memoKindListState = useState<List<String>>([]);
    final linkKindListState = useState<List<String>>([]);

    useWidgetLifecycleObserver(
      memoContentListState,
      linkContentListState,
      memoKindListState,
      linkKindListState,
    );

    return MaterialApp(
      title: 'Link & Memo Folder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSerifJP',
      ),
      home: MainTabScreen(
        memoContentListState: memoContentListState,
        linkContentListState: linkContentListState,
        memoKindListState: memoKindListState,
        linkKindListState: linkKindListState,
      ),
    );
  }
}
