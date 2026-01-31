import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'stage_models.dart';
import 'stage_card.dart';
import 'stage_controller.dart';

class StageListView extends StatelessWidget {
  final bool isDark;
  final bool isBn;

  const StageListView({
    super.key,
    required this.isDark,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StageController>();

    return Obx(
      () {
        final stages = controller.stages;
        if (stages.isEmpty) {
          return Center(
            child: Text(
              isBn ? 'কোনো স্টেজ নেই' : 'No stages',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFFB8DED6).withValues(alpha: 0.8) : const Color(0xFF9D9D9D),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          itemCount: stages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 0),
          itemBuilder: (context, index) {
            final stage = stages[index];
            return StageCard(
              stage: stage,
              isDark: isDark,
              isBn: isBn,
              onTap: () => controller.openJoinDialog(stage),
            );
          },
        );
      },
    );
  }
}
