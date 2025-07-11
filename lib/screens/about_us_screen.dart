import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title with emojis
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("💭", style: TextStyle(fontSize: 32)),
                    SizedBox(width: 10),
                    Text(
                      "About Reminest",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text("🧠", style: TextStyle(fontSize: 32)),
                  ],
                ),
                SizedBox(height: 24),
                
                // Profile photo with your Developer.png image
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.primaryColor,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/icons/Developer.png',
                      width: 108,
                      height: 108,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return CircleAvatar(
                          radius: 54,
                          backgroundColor: theme.brightness == Brightness.dark 
                              ? Colors.white24 
                              : Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: theme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // About text with border
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: theme.brightness == Brightness.dark 
                        ? Colors.white10 
                        : Colors.white,
                  ),
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "Hello! I'm Brad, the creator of Reminest. Having personally experienced mental health challenges, I understand the importance of having a safe, private space for self-reflection and emotional expression.\n\n"
                    "Reminest is designed as your secure digital sanctuary—a place where you can document your thoughts, track your emotional journey, and reflect on your growth over time. The app's core purpose is to help you identify patterns in your mental health by allowing you to revisit entries months or years later.\n\n"
                    "Key features include:\n"
                    "• Secure journal entries with vault protection\n"
                    "• Photo integration with gallery or camera options\n"
                    "• Flexible organization between main journal and secure vault\n"
                    "• Privacy-focused design with no external sharing\n\n"
                    "In a world of constant social media exposure, Reminest provides a judgment-free environment where you can express yourself authentically. Whether you're managing anxiety, depression, or simply navigating life's challenges, this app serves as your personal mental health companion.\n\n"
                    "Thank you for trusting Reminest on your journey toward better mental wellness.",
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Developer info
                Text(
                  "Developed by Bradley Murray.\n© 2025",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}