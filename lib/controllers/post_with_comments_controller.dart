import 'package:get/get.dart';
import '../core/controllers/app_controller.dart';
import '../widgets/post_with_comments.dart';

class PostWithCommentsController extends GetxController {
  final AppController appController = Get.find<AppController>();
  
  // Post state
  late PostData post;
  final RxBool isLiked = false.obs;
  final RxBool isSaved = false.obs;
  final RxInt likesCount = 0.obs;
  
  // Comments state
  final RxList<CommentReply> comments = <CommentReply>[].obs;
  final Rx<CommentReply?> replyTo = Rx<CommentReply?>(null);
  
  bool get isBn => appController.language == AppLanguage.bn;
  bool get isDark => appController.isDarkMode;
  
  void initPost(PostData postData) {
    post = postData;
    isLiked.value = postData.isLiked;
    likesCount.value = postData.likes;
    _initializeComments();
  }
  
  void handleLike() {
    if (isLiked.value) {
      likesCount.value--;
    } else {
      likesCount.value++;
    }
    isLiked.toggle();
  }
  
  void toggleSave() {
    isSaved.toggle();
  }
  
  String getAuthorInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return words[0][0] + words[1][0];
    }
    return name[0];
  }
  
  void _initializeComments() {
    comments.value = [];
  }
  
  void handleAddComment(String text) {
    final newComment = CommentReply(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: isBn ? 'আপনি' : 'You',
      authorHandle: '@you',
      initials: isBn ? 'আ' : 'Y',
      avatarColor: '#d97757',
      text: text,
      timestamp: isBn ? 'এইমাত্র' : 'Just now',
      likes: 0,
      isLiked: false,
    );

    if (replyTo.value != null) {
      _addReplyToComment(comments, replyTo.value!.id, newComment);
      replyTo.value = null;
    } else {
      comments.insert(0, newComment);
    }
    comments.refresh();
  }
  
  void _addReplyToComment(
      List<CommentReply> commentList, String parentId, CommentReply newReply) {
    for (var comment in commentList) {
      if (comment.id == parentId) {
        comment.replies ??= [];
        comment.replies!.add(newReply);
        return;
      }
      if (comment.replies != null) {
        _addReplyToComment(comment.replies!, parentId, newReply);
      }
    }
  }
  
  void handleCommentLike(String commentId) {
    _toggleLike(comments, commentId);
    comments.refresh();
  }
  
  void _toggleLike(List<CommentReply> commentList, String commentId) {
    for (var comment in commentList) {
      if (comment.id == commentId) {
        comment.isLiked = !comment.isLiked;
        comment.likes += comment.isLiked ? 1 : -1;
        return;
      }
      if (comment.replies != null) {
        _toggleLike(comment.replies!, commentId);
      }
    }
  }
  
  void handleReply(CommentReply comment) {
    replyTo.value = comment;
  }
  
  void cancelReply() {
    replyTo.value = null;
  }
  
  void handleDeleteComment(String commentId) {
    _deleteComment(comments, commentId);
    comments.refresh();
  }
  
  void _deleteComment(List<CommentReply> commentList, String commentId) {
    commentList.removeWhere((c) => c.id == commentId);
    for (var comment in commentList) {
      if (comment.replies != null) {
        _deleteComment(comment.replies!, commentId);
      }
    }
  }
  
  void loadMoreComments() {
    // TODO: Implement API call to load more comments
  }
}

