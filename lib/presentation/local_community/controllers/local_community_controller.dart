import 'package:get/get.dart';
import 'package:torko/presentation/community/controllers/community_controller.dart';

class LocalCommunityController extends GetxController {
  final Rx<CommunityTab> activeTab = CommunityTab.stages.obs;
}
