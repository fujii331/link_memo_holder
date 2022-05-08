import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InitialKindSet extends HookWidget {
  final ValueNotifier<String> selectKindState;
  final List<String> selectableKinds;

  const InitialKindSet({
    Key? key,
    required this.selectKindState,
    required this.selectableKinds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isJapanese = Localizations.localeOf(context).toString() == 'ja';
    final selectableKindsExist = selectableKinds.isNotEmpty;

    return Row(
      children: [
        Text(
          isJapanese ? '分類' : 'Kind',
          style: TextStyle(
            color: Colors.blueGrey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 15),
        Container(
          width: 150,
          alignment: Alignment.center,
          child: DropdownButton(
            isExpanded: true,
            hint: Text(
              isJapanese ? '分類なし' : 'No kind',
              style: const TextStyle(
                color: Colors.black38,
              ),
            ),
            underline: Container(
              height: 1,
              color: Colors.black38,
            ),
            value: selectKindState.value != '' ? selectKindState.value : null,
            items: selectableKinds.map((String selectableKind) {
              return DropdownMenuItem(
                value: selectableKind,
                child: Text(
                  selectableKind,
                ),
              );
            }).toList(),
            onChanged: (target) {
              selectKindState.value = target as String;
            },
          ),
        ),
      ],
    );
  }
}
