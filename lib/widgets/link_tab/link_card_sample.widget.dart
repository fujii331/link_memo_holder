import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:link_memo_holder/widgets/common/action_row.widget.dart';

class LinkCardSample extends HookWidget {
  final int sampleNumber;
  final ActionRow actionRow;

  const LinkCardSample({
    Key? key,
    required this.sampleNumber,
    required this.actionRow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFirst = sampleNumber == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Card(
        color: Colors.blueGrey.shade50,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFirst ? 'プログラミングの勉強（初心者向け）' : 'おすすめモーニングルーティン',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      height: 130,
                      child: Image(
                        image: AssetImage(
                          isFirst
                              ? 'assets/images/sample_1.png'
                              : 'assets/images/sample_2.png',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isFirst
                        ? 'プログラミングの勉強をしたい人におすすめのサイトです。人気の言語やフレームワークなどを紹介しています。'
                        : '朝早く起きてからやるべきこと10選。1日を快適に過ごすためにはこんなことをした方がいい！QOLを高める行動とは。',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey.shade700,
              height: 1,
            ),
            actionRow,
          ],
        ),
      ),
    );
  }
}
