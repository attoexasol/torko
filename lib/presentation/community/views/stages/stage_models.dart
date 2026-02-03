/// Model for a live stage in the Community feature.
class StageModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final bool isLive;
  final String hostName;
  final String hostUsername;
  final String? hostAvatar;
  final int listenersCount;
  final String durationText;

  const StageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isLive,
    required this.hostName,
    required this.hostUsername,
    this.hostAvatar,
    required this.listenersCount,
    required this.durationText,
  });
}
