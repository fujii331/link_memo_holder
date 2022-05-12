import 'dart:math';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:link_memo_holder/parts/platform_channel_specifics.part.dart';
import 'package:timezone/timezone.dart' as tz;

class TimerSetModal extends HookWidget {
  final bool isLinkTab;
  final String content;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const TimerSetModal({
    Key? key,
    required this.isLinkTab,
    required this.content,
    required this.flutterLocalNotificationsPlugin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canUpdateState = useState<bool>(true);
    final nowDateTime = tz.TZDateTime.now(tz.local);
    final thisYear = nowDateTime.year.toString();
    final thisMonth = nowDateTime.month.toString();
    final today = nowDateTime.day.toString();
    final nowHour = nowDateTime.hour.toString();
    final nowMinute = nowDateTime.minute.toString();
    final nextYearDateTime =
        tz.TZDateTime.now(tz.local).add(const Duration(hours: 24 * 365));
    final dateTextController =
        useTextEditingController(text: '$thisYear-$thisMonth-$today');
    final timeTextController =
        useTextEditingController(text: '$nowHour:$nowMinute');

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLinkTab
                ? AppLocalizations.of(context).link_timer_set
                : AppLocalizations.of(context).memo_timer_set,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 15),
          DateTimePicker(
            type: DateTimePickerType.date,
            dateMask: 'yyyy/MM/dd',
            controller: dateTextController,
            firstDate: DateTime(
              nowDateTime.year,
              nowDateTime.month,
              nowDateTime.day,
            ),
            lastDate: DateTime(
              nextYearDateTime.year,
              nextYearDateTime.month,
              nextYearDateTime.day,
            ),
            icon: const Icon(Icons.event),
            dateLabelText: AppLocalizations.of(context).date,
          ),
          DateTimePicker(
            type: DateTimePickerType.time,
            controller: timeTextController,
            icon: const Icon(Icons.access_time),
            timeLabelText: AppLocalizations.of(context).time,
            use24HourFormat: true,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).register),
            style: ElevatedButton.styleFrom(
              primary: Colors.orange.shade600,
              shape: const StadiumBorder(),
              side: BorderSide(
                width: 2,
                color: Colors.orange.shade700,
              ),
            ),
            onPressed: canUpdateState.value
                ? () async {
                    canUpdateState.value = false;
                    final splitDate = dateTextController.text.split('-');
                    final splitTime = timeTextController.text.split(':');

                    final targetTime = tz.TZDateTime(
                      tz.local,
                      int.parse(splitDate[0]),
                      int.parse(splitDate[1]),
                      int.parse(splitDate[2]),
                      int.parse(splitTime[0]),
                      int.parse(splitTime[1]),
                      0,
                    );

                    if (targetTime.isAfter(
                      tz.TZDateTime.now(tz.local),
                    )) {
                      await flutterLocalNotificationsPlugin.zonedSchedule(
                        Random().nextInt(938277757), // IDが重複して上書きしないようにする
                        isLinkTab
                            ? AppLocalizations.of(context).link_timer_title
                            : AppLocalizations.of(context).memo_timer_title,
                        content,
                        targetTime,
                        platformChannelSpecifics,
                        androidAllowWhileIdle: true,
                        uiLocalNotificationDateInterpretation:
                            UILocalNotificationDateInterpretation.absoluteTime,
                      );

                      EasyLoading.showToast(
                        AppLocalizations.of(context).notice_add +
                            dateTextController.text +
                            ' ' +
                            timeTextController.text,
                        duration: const Duration(milliseconds: 2500),
                        toastPosition: EasyLoadingToastPosition.center,
                        dismissOnTap: false,
                      );

                      Navigator.pop(context);
                    } else {
                      EasyLoading.showToast(
                        AppLocalizations.of(context).before_now,
                        duration: const Duration(milliseconds: 2500),
                        toastPosition: EasyLoadingToastPosition.center,
                        dismissOnTap: false,
                      );
                    }

                    canUpdateState.value = true;
                  }
                : () {},
          ),
        ],
      ),
    );
  }
}
