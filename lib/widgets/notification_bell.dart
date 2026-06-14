import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/notification/controller/notification_controller.dart';
import 'package:kitab_mandi/features/notification/view/notification_view.dart';

/// Reusable notification bell icon with unread badge.
/// Drop into any AppBar's [actions] list.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();
    final theme = Theme.of(context);

    return Obx(() {
      final count = ctrl.unreadCount;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: 'notifications'.tr,
            icon: Icon(
              count > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_outlined,
              size: 24,
            ),
            onPressed: () => Get.to(() => NotificationView()),
          ),
          if (count > 0)
            Positioned(
              top: 8,
              right: 8,
              child: IgnorePointer(
                child: Container(
                  height: 16,
                  constraints: const BoxConstraints(minWidth: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
