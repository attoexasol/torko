import 'package:get/get.dart';
import 'package:torko/presentation/community/views/stages/screens/stage_room_view.dart';

class CommunityRoutes {
  static const String stageRoom = '/community/stage-room';

  static List<GetPage> get pages => [
        GetPage(
          name: stageRoom,
          page: () => const StageRoomView(),
        ),
      ];
}
