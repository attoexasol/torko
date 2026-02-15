import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:torko/core/controllers/app_controller.dart';
import 'package:torko/presentation/main/controllers/navigation_controller.dart';

class BottomNav extends StatelessWidget {
  final String activeScreen;
  final bool hideNav;
  final Function(String)? onNavigate;

  const BottomNav({
    super.key,
    required this.activeScreen,
    this.hideNav = false,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    // Get or create navigation controller
    final NavigationController navController;
    if (Get.isRegistered<NavigationController>()) {
      navController = Get.find<NavigationController>();
    } else {
      navController = Get.put(NavigationController(), permanent: true);
    }

    void handleNavigate(String screen) {
      if (onNavigate != null) {
        onNavigate!(screen);
      } else {
        navController.navigateTo(screen);
      }
    }

    void handleMessageClick() {
      if (onNavigate != null) {
        appController.resetMessageNotifications();
        onNavigate!('messages');
      } else {
        navController.handleMessagesTap();
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(0, hideNav ? 100 : 0, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: hideNav ? 0.7 : 1.0,
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 768, minWidth: 350),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                height: 77,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFd6775c),
                  borderRadius: BorderRadius.circular(75),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                // Use Obx to reactively rebuild when navigation state changes
                child: Obx(() {
                  // Read reactive state from controller
                  final isHome = navController.isHome;
                  final isLocalCommunity = navController.isLocalCommunity;
                  final isMessages = navController.isMessages;
                  final isProfile = navController.isProfile;
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Home Button
                      _NavButton(
                        isActive: isHome,
                        onTap: () => handleNavigate('home'),
                        activeSize: 22,
                        inactiveSize: 26,
                        child: _HomeIcon(isActive: isHome),
                      ),
                      
                      // Community Button
                      _NavButton(
                        isActive: isLocalCommunity,
                        onTap: () => handleNavigate('localCommunity'),
                        activeSize: 42,
                        inactiveSize: 54,
                        child: _CommunityIcon(isActive: isLocalCommunity),
                      ),
                      
                      // Create Post Button (Center)
                      _CenterButton(onTap: () => handleNavigate('createPost')),
                      
                      // Messages Button (badge removed - no overlay)
                      _NavButton(
                        isActive: isMessages,
                        onTap: handleMessageClick,
                        activeSize: 20,
                        inactiveSize: 24,
                        child: _MessageIcon(isActive: isMessages),
                      ),
                      
                      // Profile Button
                      _NavButton(
                        isActive: isProfile,
                        onTap: () => handleNavigate('profile'),
                        activeSize: 20,
                        inactiveSize: 24,
                        child: _ProfileIcon(isActive: isProfile),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final double activeSize;
  final double inactiveSize;
  final Widget child;
  final int? badge;

  const _NavButton({
    required this.isActive,
    required this.onTap,
    required this.activeSize,
    required this.inactiveSize,
    required this.child,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive 
                  ? const Color(0xFFbd4e2e)
                  : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isActive 
                  ? [BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: -2,
                    )]
                  : null,
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? activeSize : inactiveSize,
                height: isActive ? activeSize : inactiveSize,
                child: child,
              ),
            ),
          ),
          // Notification Badge
          if (badge != null && badge! > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFff3b30),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    badge! > 99 ? '99+' : badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Create Post Button (Center)

class _CenterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CustomPaint(
              painter: _PlusIconPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6775C)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeIcon extends StatelessWidget {
  final bool isActive;

  const _HomeIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HomeIconPainter(isActive: isActive),
      size: Size.infinite,
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  final bool isActive;

  _HomeIconPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = isActive ? 2.5 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    path.moveTo(size.width * 0.5, size.height * 0.15);
    path.lineTo(size.width * 0.12, size.height * 0.45);
    path.moveTo(size.width * 0.5, size.height * 0.15);
    path.lineTo(size.width * 0.88, size.height * 0.45);
    
    path.moveTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.2, size.height * 0.85);
    path.lineTo(size.width * 0.8, size.height * 0.85);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    
    path.moveTo(size.width * 0.4, size.height * 0.85);
    path.lineTo(size.width * 0.4, size.height * 0.55);
    path.lineTo(size.width * 0.6, size.height * 0.55);
    path.lineTo(size.width * 0.6, size.height * 0.85);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HomeIconPainter oldDelegate) => 
      oldDelegate.isActive != isActive;
}

class _CommunityIcon extends StatelessWidget {
  final bool isActive;

  const _CommunityIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.people_outline,
      color: Colors.white,
      size: isActive ? 28 : 32,
    );
  }
}

class _MessageIcon extends StatelessWidget {
  final bool isActive;

  const _MessageIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MessageIconPainter(isActive: isActive),
      size: Size.infinite,
    );
  }
}

class _MessageIconPainter extends CustomPainter {
  final bool isActive;

  _MessageIconPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = isActive ? 2.5 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.08,
        size.width * 0.84,
        size.height * 0.58,
      ),
      Radius.circular(size.width * 0.08),
    );
    path.addRRect(rect);
    
    canvas.drawPath(path, paint);
    
    final tailPath = Path();
    tailPath.moveTo(size.width * 0.08, size.height * 0.66);
    tailPath.lineTo(size.width * 0.08, size.height * 0.92);
    tailPath.lineTo(size.width * 0.35, size.height * 0.66);
    
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(covariant _MessageIconPainter oldDelegate) => 
      oldDelegate.isActive != isActive;
}

class _ProfileIcon extends StatelessWidget {
  final bool isActive;

  const _ProfileIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProfileIconPainter(isActive: isActive),
      size: Size.infinite,
    );
  }
}

class _ProfileIconPainter extends CustomPainter {
  final bool isActive;

  _ProfileIconPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = isActive ? 2.5 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.3),
        width: size.width * 0.4,
        height: size.height * 0.4,
      ),
      paint,
    );

    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.15, size.height * 0.92);
    bodyPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.55,
      size.width * 0.85, size.height * 0.92,
    );
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ProfileIconPainter oldDelegate) => 
      oldDelegate.isActive != isActive;
}
