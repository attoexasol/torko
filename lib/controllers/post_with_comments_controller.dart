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
    comments.value = [
      CommentReply(
        id: '1',
        author: isBn ? 'সাকিব হাসান' : 'Sakib Hasan',
        authorHandle: '@sakibhasan',
        initials: isBn ? 'সা' : 'SH',
        avatarColor: '#d97757',
        text: isBn
            ? 'দারুণ পোস্ট! আমি সম্পূর্ণ একমত আপনার সাথে। এই বিষয়ে আরো বিস্তারিত জানতে চাই।'
            : 'Great post! I completely agree with you. Would love to know more about this topic.',
        timestamp: isBn ? '২ ঘণ্টা আগে' : '2h ago',
        likes: 24,
        isLiked: true,
        replies: [
          CommentReply(
            id: '1-1',
            author: isBn ? 'তানিয়া আক্তার' : 'Tania Akter',
            authorHandle: '@taniaakter',
            initials: isBn ? 'তা' : 'TA',
            avatarColor: '#6B9BD1',
            text: isBn
                ? 'আমি একই কথা ভাবছিলাম! খুব ভালো লাগলো।'
                : 'I was thinking the same thing! Really glad to see this.',
            timestamp: isBn ? '১ ঘণ্টা আগে' : '1h ago',
            likes: 8,
            isLiked: false,
            replies: [
              CommentReply(
                id: '1-1-1',
                author: isBn ? 'রাফি খান' : 'Rafi Khan',
                authorHandle: '@rafikhan',
                initials: isBn ? 'রা' : 'RK',
                avatarColor: '#9333ea',
                text: isBn
                    ? 'একদম সঠিক বলেছেন দুজনেই!'
                    : 'Both of you are absolutely right!',
                timestamp: isBn ? '৩০ মিনিট আগে' : '30m ago',
                likes: 3,
                isLiked: false,
              ),
            ],
          ),
          CommentReply(
            id: '1-2',
            author: isBn ? 'নাফিস রহমান' : 'Nafis Rahman',
            authorHandle: '@nafisrahman',
            initials: isBn ? 'না' : 'NR',
            avatarColor: '#16a34a',
            text: isBn
                ? 'চমৎকার insight! আরো এমন content চাই।'
                : 'Amazing insight! Need more content like this.',
            timestamp: isBn ? '৪৫ মিনিট আগে' : '45m ago',
            likes: 5,
            isLiked: false,
          ),
        ],
      ),
      CommentReply(
        id: '2',
        author: isBn ? 'মাহমুদা খাতুন' : 'Mahmuda Khatun',
        authorHandle: '@mahmudakhatun',
        initials: isBn ? 'মা' : 'MK',
        avatarColor: '#ea580c',
        text: isBn
            ? 'এই তথ্যটা অনেক কাজের! শেয়ার করার জন্য ধন্যবাদ।'
            : 'This information is very useful! Thanks for sharing.',
        timestamp: isBn ? '৩ ঘণ্টা আগে' : '3h ago',
        likes: 15,
        isLiked: false,
      ),
      CommentReply(
        id: '3',
        author: isBn ? 'ইমরান হোসেন' : 'Imran Hossain',
        authorHandle: '@imranhossain',
        initials: isBn ? 'ই' : 'IH',
        avatarColor: '#8B9FA8',
        text: isBn
            ? 'খুবই informative post। আমার অনেক confusion clear হলো।'
            : 'Very informative post. Cleared a lot of my confusion.',
        timestamp: isBn ? '৫ ঘণ্টা আগে' : '5h ago',
        likes: 32,
        isLiked: false,
        replies: [
          CommentReply(
            id: '3-1',
            author: isBn ? 'সায়মা বেগম' : 'Sayma Begum',
            authorHandle: '@saymabegum',
            initials: isBn ? 'সা' : 'SB',
            avatarColor: '#ec4899',
            text: isBn
                ? 'আমারও! অনেক কিছু শিখলাম।'
                : 'Mine too! Learned a lot.',
            timestamp: isBn ? '৪ ঘণ্টা আগে' : '4h ago',
            likes: 7,
            isLiked: false,
          ),
        ],
      ),
    ];
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

