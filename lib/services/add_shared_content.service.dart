import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void addSharedContent(
  String content,
  ValueNotifier<List<String>> memoContentListState,
  ValueNotifier<List<String>> linkContentListState,
  ValueNotifier<List<String>> memoKindListState,
  ValueNotifier<List<String>> linkKindListState,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // 正規表現
  RegExp regExp = RegExp(
      r'((https?:\/\/)|(https?:www\.)|(www\.))[a-zA-Z0-9-]{1,256}\.[a-zA-Z0-9]{2,6}(\/[a-zA-Z0-9亜-熙ぁ-んァ-ヶ()@:%_\+.~#?&\/=-]*)?');

  if (regExp.hasMatch(content)) {
    // urlが渡ってきた場合
    linkContentListState.value.add(content);
    linkKindListState.value.add('0');
    prefs.setStringList('linkContentList', linkContentListState.value);
    prefs.setStringList('linkKindList', linkKindListState.value);

    print("linkに追加: $content");
  } else {
    // url以外の場合
    memoContentListState.value.add(content);
    memoKindListState.value.add('0');
    prefs.setStringList('memoContentList', memoContentListState.value);
    prefs.setStringList('memoKindList', memoKindListState.value);

    print("memoに追加: $content");
  }
}
