import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  ValueNotifier<List<String>> memoContentsState,
  ValueNotifier<List<String>> linkContentsState,
  ValueNotifier<List<String>> memoKindsState,
  ValueNotifier<List<String>> linkKindsState,
) {
  return use(_WidgetObserver(
    memoContentsState,
    linkContentsState,
    memoKindsState,
    linkKindsState,
  ));
}

class _WidgetObserver extends Hook<void> {
  final ValueNotifier<List<String>> memoContentsState;
  final ValueNotifier<List<String>> linkContentsState;
  final ValueNotifier<List<String>> memoKindsState;
  final ValueNotifier<List<String>> linkKindsState;

  const _WidgetObserver(
    this.memoContentsState,
    this.linkContentsState,
    this.memoKindsState,
    this.linkKindsState,
  );

  @override
  HookState<void, Hook<void>> createState() {
    return _WidgetObserverState(
      memoContentsState,
      linkContentsState,
      memoKindsState,
      linkKindsState,
    );
  }
}

class _WidgetObserverState extends HookState<void, _WidgetObserver>
    with WidgetsBindingObserver {
  final ValueNotifier<List<String>> memoContentsState;
  final ValueNotifier<List<String>> linkContentsState;
  final ValueNotifier<List<String>> memoKindsState;
  final ValueNotifier<List<String>> linkKindsState;

  _WidgetObserverState(
    this.memoContentsState,
    this.linkContentsState,
    this.memoKindsState,
    this.linkKindsState,
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
        memoContentsState,
        linkContentsState,
        memoKindsState,
        linkKindsState,
      );
    }, onError: (err) {
      print("共有に失敗しました error: $err");
    });

    // アプリ停止中の共有
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value != null) {
        addSharedContent(
          value,
          memoContentsState,
          linkContentsState,
          memoKindsState,
          linkKindsState,
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
    final memoContentsState = useState<List<String>>([]);
    final linkContentsState = useState<List<String>>([]);
    final memoKindsState = useState<List<String>>([]);
    final linkKindsState = useState<List<String>>([]);

    useWidgetLifecycleObserver(
      memoContentsState,
      linkContentsState,
      memoKindsState,
      linkKindsState,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      title: 'Link・Memo Holder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansJP',
      ),
      home: MainTabScreen(
        memoContentsState: memoContentsState,
        linkContentsState: linkContentsState,
        memoKindsState: memoKindsState,
        linkKindsState: linkKindsState,
      ),
    );
  }
}
