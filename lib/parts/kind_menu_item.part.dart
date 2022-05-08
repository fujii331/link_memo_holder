import 'package:flutter/material.dart';

PopupMenuItem<String> kindMenuItem(
  String? selectKind,
  String targetKind,
) {
  return PopupMenuItem<String>(
    value: targetKind,
    child: Row(
      children: [
        selectKind == targetKind
            ? const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.green,
                ),
              )
            : const SizedBox(
                width: 27,
              ),
        Text(
          targetKind,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}
