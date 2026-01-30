import 'package:get/get.dart';

enum CommunityTab { stages, groups }

class LocalCommunityController extends GetxController {
  final Rx<CommunityTab> activeTab = CommunityTab.stages.obs;
}
