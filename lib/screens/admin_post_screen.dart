// // lib/screens/admin_post_screen.dart

// import 'package:flutter/material.dart';
// import 'admin_create_event_screen.dart'; // Import the Event Creation Page

// class AdminPostScreen extends StatelessWidget {
//   const AdminPostScreen({super.key});

//   // Function to navigate to the Event Creation Page
//   void _navigateToCreateEvent(BuildContext context) {
//     Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (context) => const CreateEventScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.blue.shade50,
//             Colors.purple.shade50,
//             Colors.pink.shade50,
//           ],
//         ),
//       ),
//       child: Stack(
//         children: [
//           // Decorative floating circles
//           Positioned(
//             top: 100,
//             left: 30,
//             child: _buildFloatingCircle(
//               size: 80,
//               color: Colors.blue.withOpacity(0.1),
//             ),
//           ),
//           Positioned(
//             top: 200,
//             right: 50,
//             child: _buildFloatingCircle(
//               size: 60,
//               color: Colors.purple.withOpacity(0.1),
//             ),
//           ),
//           Positioned(
//             bottom: 150,
//             left: 60,
//             child: _buildFloatingCircle(
//               size: 100,
//               color: Colors.pink.withOpacity(0.08),
//             ),
//           ),
          
//           // Main content
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Animated icon container
//                 TweenAnimationBuilder<double>(
//                   duration: const Duration(milliseconds: 800),
//                   tween: Tween(begin: 0.0, end: 1.0),
//                   curve: Curves.elasticOut,
//                   builder: (context, value, child) {
//                     return Transform.scale(
//                       scale: value,
//                       child: child,
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.blue.shade300.withOpacity(0.3),
//                           Colors.purple.shade300.withOpacity(0.3),
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.withOpacity(0.2),
//                           blurRadius: 30,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Colors.blue.shade400, Colors.purple.shade400],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.purple.withOpacity(0.4),
//                             blurRadius: 20,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.create,
//                         size: 48,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 40),
                
//                 // Title with animation
//                 TweenAnimationBuilder<double>(
//                   duration: const Duration(milliseconds: 600),
//                   tween: Tween(begin: 0.0, end: 1.0),
//                   curve: Curves.easeOut,
//                   builder: (context, value, child) {
//                     return Opacity(
//                       opacity: value,
//                       child: Transform.translate(
//                         offset: Offset(0, 20 * (1 - value)),
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     'Create New Event',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A1A2E),
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 12),
                
//                 // Subtitle with animation
//                 TweenAnimationBuilder<double>(
//                   duration: const Duration(milliseconds: 800),
//                   tween: Tween(begin: 0.0, end: 1.0),
//                   curve: Curves.easeOut,
//                   builder: (context, value, child) {
//                     return Opacity(
//                       opacity: value,
//                       child: Transform.translate(
//                         offset: Offset(0, 20 * (1 - value)),
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: Container(
//                     constraints: const BoxConstraints(maxWidth: 320),
//                     child: Text(
//                       'Share exciting events with your community',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade600,
//                         height: 1.5,
//                       ),
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 48),
                
//                 // Enhanced Post Button with pulsing animation
//                 TweenAnimationBuilder<double>(
//                   duration: const Duration(milliseconds: 1000),
//                   tween: Tween(begin: 0.0, end: 1.0),
//                   curve: Curves.easeOut,
//                   builder: (context, value, child) {
//                     return Opacity(
//                       opacity: value,
//                       child: Transform.scale(
//                         scale: 0.8 + (0.2 * value),
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: _PulsingButton(
//                     onPressed: () => _navigateToCreateEvent(context),
//                   ),
//                 ),
                
//                 const SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method for floating decorative circles
//   Widget _buildFloatingCircle({
//     required double size,
//     required Color color,
//   }) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//       ),
//     );
//   }
// }

// // Custom pulsing button widget
// class _PulsingButton extends StatefulWidget {
//   final VoidCallback onPressed;

//   const _PulsingButton({required this.onPressed});

//   @override
//   State<_PulsingButton> createState() => _PulsingButtonState();
// }

// class _PulsingButtonState extends State<_PulsingButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat(reverse: true);

//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: child,
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue.shade500, Colors.purple.shade500],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.4),
//               blurRadius: 20,
//               spreadRadius: 2,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: ElevatedButton.icon(
//           onPressed: widget.onPressed,
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.star, color: Colors.white, size: 20),
//           ),
//           label: const Text(
//             'Post',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//             elevation: 0,
//             shadowColor: Colors.transparent,
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/screens/admin_post_screen.dart

import 'package:flutter/material.dart';
import 'admin_create_event_screen.dart'; // Import the Event Creation Page

class AdminPostScreen extends StatelessWidget {
  const AdminPostScreen({super.key});

  // Function to navigate to the Event Creation Page
  void _navigateToCreateEvent(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateEventScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
            Colors.pink.shade50,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative floating circles
          Positioned(
            top: 100,
            left: 30,
            child: _buildFloatingCircle(
              size: 80,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
          Positioned(
            top: 200,
            right: 50,
            child: _buildFloatingCircle(
              size: 60,
              color: Colors.purple.withOpacity(0.1),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 60,
            child: _buildFloatingCircle(
              size: 100,
              color: Colors.pink.withOpacity(0.08),
            ),
          ),
          
          // Main content - FIXED WITH SCROLLVIEW
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated icon container
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade300.withOpacity(0.3),
                              Colors.purple.shade300.withOpacity(0.3),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.purple.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.create,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Title with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        'Create New Event',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Subtitle with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          'Share exciting events with your community',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Enhanced Post Button with pulsing animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: child,
                          ),
                        );
                      },
                      child: _PulsingButton(
                        onPressed: () => _navigateToCreateEvent(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for floating decorative circles
  Widget _buildFloatingCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Custom pulsing button widget
class _PulsingButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PulsingButton({required this.onPressed});

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.purple.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 20),
          ),
          label: const Text(
            'Post',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}