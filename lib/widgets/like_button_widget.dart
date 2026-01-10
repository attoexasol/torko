import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';

/// A reusable, social-media-style Like button widget with smooth animations.
/// Supports optimistic updates, API sync, and rollback on failure.
class LikeButtonWidget extends StatefulWidget {
  final int postId;
  final bool isLiked;
  final int likeCount;
  final String apiToken;
  final double iconSize;
  final Color likedColor;
  final Color unlikedColor;
  final TextStyle? countStyle;
  final void Function(bool isLiked, int likeCount)? onLikeChanged;

  const LikeButtonWidget({
    super.key,
    required this.postId,
    required this.isLiked,
    required this.likeCount,
    required this.apiToken,
    this.iconSize = 24.0,
    this.likedColor = const Color(0xFFE91E63),
    this.unlikedColor = Colors.grey,
    this.countStyle,
    this.onLikeChanged,
  });

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  bool _isLoading = false;
  
  // Animation controller for the bounce/scale effect
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = widget.likeCount;
    
    // Setup bounce animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  @override
  void didUpdateWidget(LikeButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state if parent widget provides new values
    if (oldWidget.isLiked != widget.isLiked || 
        oldWidget.likeCount != widget.likeCount) {
      if (!_isLoading) {
        setState(() {
          _isLiked = widget.isLiked;
          _likeCount = widget.likeCount;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLikeTap() async {
    // Prevent rapid taps while loading
    if (_isLoading) return;
    
    // Store original state for rollback
    final bool originalIsLiked = _isLiked;
    final int originalLikeCount = _likeCount;
    
    // Optimistic update
    setState(() {
      _isLoading = true;
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });
    
    // Play animation
    _animationController.forward(from: 0);
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    try {
      // Make API call
      final response = await NetworkCaller.postRequest(
        url: Urls.like_create,
        body: {
          'api_token': widget.apiToken,
          'post_id': widget.postId,
        },
      );
      
      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          // Sync with API response
          final int likeStatus = response.body!['like'] ?? (_isLiked ? 1 : 0);
          final int postLikeCount = response.body!['post_like_count'] ?? _likeCount;
          
          setState(() {
            _isLiked = likeStatus == 1;
            _likeCount = postLikeCount;
            _isLoading = false;
          });
          
          // Notify parent of the change
          widget.onLikeChanged?.call(_isLiked, _likeCount);
        } else {
          // API returned false status - rollback
          _rollback(originalIsLiked, originalLikeCount);
        }
      } else {
        // API call failed - rollback
        _rollback(originalIsLiked, originalLikeCount);
      }
    } catch (e) {
      // Exception occurred - rollback
      debugPrint('LikeButtonWidget: Error - $e');
      _rollback(originalIsLiked, originalLikeCount);
    }
  }
  
  void _rollback(bool originalIsLiked, int originalLikeCount) {
    setState(() {
      _isLiked = originalIsLiked;
      _likeCount = originalLikeCount;
      _isLoading = false;
    });
    
    // Haptic feedback for error
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLikeTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated heart icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(_isLiked),
                  size: widget.iconSize,
                  color: _isLiked ? widget.likedColor : widget.unlikedColor,
                ),
              ),
            ),
            
            const SizedBox(width: 6),
            
            // Like count with animated transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _formatCount(_likeCount),
                key: ValueKey<int>(_likeCount),
                style: widget.countStyle ?? TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _isLiked ? widget.likedColor : widget.unlikedColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Format large numbers (e.g., 1000 → 1K, 1000000 → 1M)
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}


/// A compact version of the like button (icon only, no count)
class LikeButtonIconOnly extends StatefulWidget {
  final int postId;
  final bool isLiked;
  final String apiToken;
  final double iconSize;
  final Color likedColor;
  final Color unlikedColor;
  final void Function(bool isLiked, int likeCount)? onLikeChanged;

  const LikeButtonIconOnly({
    super.key,
    required this.postId,
    required this.isLiked,
    required this.apiToken,
    this.iconSize = 24.0,
    this.likedColor = const Color(0xFFE91E63),
    this.unlikedColor = Colors.grey,
    this.onLikeChanged,
  });

  @override
  State<LikeButtonIconOnly> createState() => _LikeButtonIconOnlyState();
}

class _LikeButtonIconOnlyState extends State<LikeButtonIconOnly>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_animationController);
  }

  @override
  void didUpdateWidget(LikeButtonIconOnly oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked && !_isLoading) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLikeTap() async {
    if (_isLoading) return;
    
    final bool originalIsLiked = _isLiked;
    
    setState(() {
      _isLoading = true;
      _isLiked = !_isLiked;
    });
    
    _animationController.forward(from: 0);
    HapticFeedback.lightImpact();
    
    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.like_create,
        body: {
          'api_token': widget.apiToken,
          'post_id': widget.postId,
        },
      );
      
      if (response.isSuccess && response.body != null) {
        if (response.body!['status'] == true) {
          final int likeStatus = response.body!['like'] ?? (_isLiked ? 1 : 0);
          final int postLikeCount = response.body!['post_like_count'] ?? 0;
          
          setState(() {
            _isLiked = likeStatus == 1;
            _isLoading = false;
          });
          
          widget.onLikeChanged?.call(_isLiked, postLikeCount);
        } else {
          _rollback(originalIsLiked);
        }
      } else {
        _rollback(originalIsLiked);
      }
    } catch (e) {
      debugPrint('LikeButtonIconOnly: Error - $e');
      _rollback(originalIsLiked);
    }
  }
  
  void _rollback(bool originalIsLiked) {
    setState(() {
      _isLiked = originalIsLiked;
      _isLoading = false;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLikeTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey<bool>(_isLiked),
              size: widget.iconSize,
              color: _isLiked ? widget.likedColor : widget.unlikedColor,
            ),
          ),
        ),
      ),
    );
  }
}
