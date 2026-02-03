import 'package:get/get.dart';
import 'package:torko/presentation/community/controllers/community_groups_controller.dart';
import 'package:torko/presentation/community/views/stages/stage_controller.dart';
import 'package:torko/presentation/community/controllers/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CommunityController());
    Get.put(CommunityGroupsController());
    Get.put(StageController());
  }
}
