import 'package:get/get.dart';

enum CommunityTab { stages, groups }

class CommunityController extends GetxController {
  final Rx<CommunityTab> activeTab = CommunityTab.stages.obs;

  void setTab(CommunityTab tab) {
    activeTab.value = tab;
  }
}
