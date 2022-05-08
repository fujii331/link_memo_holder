import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void addSharedContent(
  String content,
  ValueNotifier<List<String>> memoContentsState,
  ValueNotifier<List<String>> linkContentsState,
  ValueNotifier<List<String>> memoKindsState,
  ValueNotifier<List<String>> linkKindsState,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // 正規表現
  RegExp regExp = RegExp(
      r'((https?:\/\/)|(https?:www\.)|(www\.))[a-zA-Z0-9-]{1,256}\.[a-zA-Z0-9]{2,6}(\/[a-zA-Z0-9亜-熙ぁ-んァ-ヶ()@:%_\+.~#?&\/=-]*)?');

  if (regExp.hasMatch(content)) {
    // urlが渡ってきた場合
    linkContentsState.value.add(content);
    linkKindsState.value.add('');
    prefs.setStringList('linkContents', linkContentsState.value);
    prefs.setStringList('linkKinds', linkKindsState.value);

    print("linkに追加: $content");
  } else {
    // url以外の場合
    memoContentsState.value.add(content);
    memoKindsState.value.add('');
    prefs.setStringList('memoContents', memoContentsState.value);
    prefs.setStringList('memoKinds', memoKindsState.value);

    print("memoに追加: $content");
  }
}
