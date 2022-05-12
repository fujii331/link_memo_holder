import 'package:link_memo_holder/widgets/link_tab/link_card.widget.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

class LinkCardItem {
  final LinkCard linkCard;
  final Uri uri;
  final Metadata? metadata;
  final String url;

  const LinkCardItem({
    required this.linkCard,
    required this.uri,
    required this.metadata,
    required this.url,
  });
}
