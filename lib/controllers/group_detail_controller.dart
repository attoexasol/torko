import 'package:get/get.dart';
import '../models/community_group_model.dart';
import '../services/community_group_api_service.dart';

class GroupDetailController extends GetxController {
  final Rx<CommunityGroupModel?> group = Rx<CommunityGroupModel?>(null);
  final RxBool loading = true.obs;
  final RxString error = ''.obs;

  Future<void> fetchGroup(int id) async {
    loading.value = true;
    error.value = '';
    group.value = null;
    try {
      final g = await CommunityGroupApiService.fetchSingleGroup(id);
      group.value = g;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }
}
