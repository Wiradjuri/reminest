import 'package:flutter/material.dart';
import 'package:reminest/screens/journal_screen.dart';

// Defining a stateless widget for the About Us screen
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Getting the current theme

    return Scaffold(
      // Main scaffold for the screen
      backgroundColor:
          theme.scaffoldBackgroundColor, // Setting background color from theme
      appBar: AppBar(
        // App bar at the top
        title: Text("About Us"), // Title of the app bar
        backgroundColor: theme.primaryColor, // App bar background color
        foregroundColor: Colors.white, // App bar text/icon color
        elevation: 0, // No shadow under the app bar
      ),
      body: Center(
        // Centering the body content
        child: SingleChildScrollView(
          // Allows scrolling if content overflows
          child: Padding(
            // Padding around the content
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32,
            ), // Horizontal and vertical padding
            child: Column(
              // Arranging widgets vertically
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centering column content
              children: [
                // Title with emojis
                Row(
                  // Row for title and emojis
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centering row content
                  children: [
                    Text(
                      "💭",
                      style: TextStyle(fontSize: 32),
                    ), // Emoji before title
                    SizedBox(width: 10), // Spacing between emoji and title
                    Text(
                      "About Reminest", // Title text
                      style: TextStyle(
                        fontSize: 32, // Title font size
                        fontWeight: FontWeight.bold, // Bold title
                        color: theme
                            .textTheme
                            .titleLarge
                            ?.color, // Title color from theme
                        letterSpacing: 2, // Spacing between letters
                      ),
                    ),
                    SizedBox(width: 10), // Spacing between title and emoji
                    Text(
                      "🧠",
                      style: TextStyle(fontSize: 32),
                    ), // Emoji after title
                  ],
                ),
                SizedBox(height: 24), // Spacing below title
                // Developer image
                Container(
                  width: 120, // Image container width
                  height: 120, // Image container height
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Circular shape
                    border: Border.all(
                      color: theme.primaryColor, // Border color from theme
                      width: 3, // Border width
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(
                          0.3,
                        ), // Shadow color
                        blurRadius: 10, // Shadow blur
                        offset: Offset(0, 4), // Shadow offset
                      ),
                    ],
                  ),
                  child: ClipOval(
                    // Clipping image to oval (circle)
                    child: Image.asset(
                      'lib/assets/icons/Developer.png', // Path to developer image
                      width: 120, // Image width
                      height: 120, // Image height
                      fit: BoxFit.cover, // Cover the container
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image fails to load
                        return CircleAvatar(
                          radius: 54, // Avatar radius
                          backgroundColor: theme.brightness == Brightness.dark
                              ? Colors
                                    .white24 // Background for dark mode
                              : Colors
                                    .grey
                                    .shade300, // Background for light mode
                          child: Icon(
                            Icons.person, // Default person icon
                            size: 60, // Icon size
                            color: theme.primaryColor, // Icon color from theme
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20), // Spacing below image
                // Journal navigation button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JournalScreen()),
                      );
                    },
                    icon: Icon(Icons.book, size: 24),
                    label: Text(
                      'Open Journal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start writing your mental health journey',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                // About text with border
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.primaryColor, // Border color from theme
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                    color: theme.brightness == Brightness.dark
                        ? Colors
                              .white10 // Background for dark mode
                        : Colors.white, // Background for light mode
                  ),
                  padding: EdgeInsets.all(24), // Padding inside container
                  child: Text(
                    "Hello! I'm Brad, the creator of Reminest. Having personally experienced mental health challenges, I understand the importance of having a safe, private space for self-reflection and emotional expression.\n\n"
                    "Reminest is designed as your secure digital sanctuary—a place where you can document your thoughts, track your emotional journey, and reflect on your growth over time. The app's core purpose is to help you identify patterns in your mental health by allowing you to revisit entries months or years later.\n\n"
                    "Key features include:\n"
                    "• Secure journal entries with vault protection\n"
                    "• Photo integration with gallery or camera options\n"
                    "• Flexible organization between main journal and secure vault\n"
                    "• Privacy-focused design with no external sharing\n\n"
                    "In a world of constant social media exposure, Reminest provides a judgment-free environment where you can express yourself authentically. Whether you're managing anxiety, depression, or simply navigating life's challenges, this app serves as your personal mental health companion.\n\n"
                    "Thank you for trusting Reminest on your journey toward better mental wellness.", // About text
                    style: TextStyle(
                      fontSize: 15, // Text font size
                      color: theme
                          .textTheme
                          .bodyMedium
                          ?.color, // Text color from theme
                      height: 1.5, // Line height
                    ),
                    textAlign: TextAlign.left, // Align text to left
                  ),
                ),
                SizedBox(height: 24), // Spacing below about text
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