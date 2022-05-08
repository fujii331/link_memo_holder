import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'dart:math';

class LoadingModal extends StatelessWidget {
  const LoadingModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final randomNumber = Random().nextInt(3);

    return WillPopScope(
      onWillPop: () async => false,
      child: Theme(
        data: Theme.of(context)
            .copyWith(dialogBackgroundColor: Colors.white.withOpacity(0.0)),
        child: SimpleDialog(
          children: <Widget>[
            const Text(
              'ロード中...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'KaiseiOpti',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),
            randomNumber == 0
                ? SpinKitFadingCube(
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.lightBlue : Colors.blue,
                        ),
                      );
                    },
                  )
                : randomNumber == 1
                    ? SpinKitWave(
                        color: Colors.indigo.shade200,
                        size: 50.0,
                      )
                    : randomNumber == 2
                        ? SpinKitWanderingCubes(
                            color: Colors.orange.shade200,
                            size: 50.0,
                          )
                        : const SpinKitCubeGrid(color: Colors.yellow),
          ],
        ),
      ),
    );
  }
}
