import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MainTabScreen extends HookWidget {
  static const routeName = '/main-tab';

  final ValueNotifier<List<String>> memoContentListState;
  final ValueNotifier<List<String>> linkContentListState;
  final ValueNotifier<List<String>> memoKindListState;
  final ValueNotifier<List<String>> linkKindListState;

  const MainTabScreen({
    Key? key,
    required this.memoContentListState,
    required this.linkContentListState,
    required this.memoKindListState,
    required this.linkKindListState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenNo = useState<int>(0);
    final pageController = usePageController(initialPage: 0, keepPage: true);

    return Container(
      // decoration: const BoxDecoration(
      //   image: DecorationImage(
      //     image:
      //         AssetImage('assets/images/background/quiz_datail_tab_back.jpg'),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Scaffold(
        backgroundColor: const Color(0x15555555),
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: screenNo.value,
          onItemSelected: (index) {
            screenNo.value = index;
            pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          },
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              title: const Text('Link'),
              icon: const Icon(Icons.web),
            ),
            BottomNavyBarItem(
              title: const Text('Memo'),
              icon: const Icon(Icons.note),
            ),
          ],
        ),
        body: PageView(
          controller: pageController,
          // ページ切り替え時に実行する処理
          onPageChanged: (index) {
            screenNo.value = index;
          },
          children: [
            QuizDetail(
              quiz: quiz,
              subjectController: subjectController,
              relatedWordController: relatedWordController,
            ),
            Questioned(
              quizId: quiz.id,
            )
          ],
        ),
      ),
    );
  }
}
