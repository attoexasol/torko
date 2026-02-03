import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'stage_models.dart';
import 'stage_join_dialog.dart';
import 'package:torko/presentation/community/_legacy_duplicates/stage_room_view_from_views.dart';
import 'end_stage_dialog.dart';

class StageController extends GetxController {
  final RxList<StageModel> stages = <StageModel>[].obs;
  final Rxn<StageModel> selectedStage = Rxn<StageModel>();

  @override
  void onInit() {
    super.onInit();
    _loadMockStages();
  }

  void _loadMockStages() {
    stages.value = [
      const StageModel(
        id: 1,
        title: 'Startup Success Secrets',
        description: 'Learn from experienced founders',
        category: 'Business',
        isLive: true,
        hostName: 'Rifat Hassan',
        hostUsername: 'rifat_h',
        hostAvatar: null,
        listenersCount: 234,
        durationText: '45 min',
      ),
      const StageModel(
        id: 2,
        title: 'Future of AI and Machine Learning',
        description: 'Exploring the next frontier',
        category: 'Technology',
        isLive: true,
        hostName: 'Mehedi Hasan',
        hostUsername: 'mehedi_h',
        hostAvatar: null,
        listenersCount: 567,
        durationText: '1 hour',
      ),
      const StageModel(
        id: 3,
        title: 'Bangla Poetry Reading & Discussion',
        description: 'Classic and modern poetry',
        category: 'Literature',
        isLive: true,
        hostName: 'Nusrat Jahan',
        hostUsername: 'nusrat_j',
        hostAvatar: null,
        listenersCount: 123,
        durationText: '30 min',
      ),
    ];
  }

  void openJoinDialog(StageModel stage) {
    selectedStage.value = stage;
    final isBn = Get.isRegistered<AppController>() &&
        Get.find<AppController>().language == AppLanguage.bn;
    StageJoinDialog.show(stage, isBn);
  }

  void joinStage(StageModel stage) {
    Get.back();
    Get.to(() => StageRoomView(stage: stage));
  }

  void endStageConfirm() {
    EndStageDialog.show(
      onConfirm: () => Get.back(),
    );
  }
}
