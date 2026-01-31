import 'package:get/get.dart';
import '../../controllers/community_groups_controller.dart';
import '../../views/community/stages/stage_controller.dart';
import 'controllers/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CommunityController());
    Get.put(CommunityGroupsController());
    Get.put(StageController());
  }
}
