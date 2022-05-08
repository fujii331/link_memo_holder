import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';

Future<Metadata?> fetchOgp(
  Uri uri,
) async {
  // 参考 https://github.com/popy1017/flutter_fetch_ogp/blob/master/lib/models/metadata_model.dart
  // 分類を更新
  try {
    final response = await http.get(uri);
    final document = MetadataFetch.responseToDocument(response);
    final ogp = MetadataParser.openGraph(document);

    return ogp;
  } catch (e) {
    return null;
  }
}
