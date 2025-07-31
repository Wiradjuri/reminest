import 'package:flutter/material.dart'; // Importing Flutter Material package for UI components.
import 'package:reminest/screens/journal_screen.dart'; // Importing the JournalScreen widget for navigation.

// Defining a stateless widget for the About Us screen.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key}); // Constructor with optional key parameter.

  @override
  Widget build(BuildContext context) { // Overriding the build method to construct the widget.
    final theme = Theme.of(context); // Obtaining the current theme data.

    return Scaffold( // Scaffold provides the basic visual layout structure.
      body: Center( // Centers the body content vertically and horizontally.
        child: SingleChildScrollView( // Enables scrolling if content exceeds screen height.
          child: Padding( // Adds padding around the content.
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32,
            ), // Specifies horizontal and vertical padding values.
            child: Column( // Arranges child widgets vertically.
              mainAxisAlignment: MainAxisAlignment.center, // Centers column content vertically.
              children: [
                Row( // Arranges title and emojis horizontally.
                  mainAxisAlignment: MainAxisAlignment.center, // Centers row content horizontally.
                  children: [
                    Text(
                      "💭",
                      style: TextStyle(fontSize: 32),
                    ), // Displays emoji before the title.
                    SizedBox(width: 10), // Adds horizontal spacing.
                    Text(
                      "About Reminest", // Displays the title text.
                      style: TextStyle(
                        fontSize: 32, // Sets font size for the title.
                        fontWeight: FontWeight.bold, // Sets title font to bold.
                        color: theme.textTheme.titleLarge?.color, // Uses theme color for title.
                        letterSpacing: 2, // Adds spacing between title letters.
                      ),
                    ),
                    SizedBox(width: 10), // Adds horizontal spacing.
                    Text(
                      "🧠",
                      style: TextStyle(fontSize: 32),
                    ), // Displays emoji after the title.
                  ],
                ),
                SizedBox(height: 24), // Adds vertical spacing below the title.
                Container(
                  width: 120, // Sets image container width.
                  height: 120, // Sets image container height.
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Makes the container circular.
                    border: Border.all(
                      color: theme.primaryColor, // Uses theme primary color for border.
                      width: 3, // Sets border width.
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3), // Adds shadow color with opacity.
                        blurRadius: 10, // Sets blur radius for shadow.
                        offset: Offset(0, 4), // Sets shadow offset.
                      ),
                    ],
                  ),
                  child: ClipOval( // Clips the child widget to a circle.
                    child: Image.asset(
                      'lib/assets/icons/Developer.png', // Path to developer image asset.
                      width: 120, // Image width.
                      height: 120, // Image height.
                      fit: BoxFit.cover, // Scales and crops the image to cover the box.
                      errorBuilder: (context, error, stackTrace) { // Handles image load errors.
                        return CircleAvatar(
                          radius: 54, // Sets the avatar's radius.
                          backgroundColor: theme.brightness == Brightness.dark
                              ? Colors.white24 // Sets background for dark theme.
                              : Colors.grey.shade300, // Sets background for light theme.
                          child: Icon(
                            Icons.person, // Displays default person icon.
                            size: 60, // Icon size.
                            color: theme.primaryColor, // Icon color from theme.
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20), // Adds vertical spacing below the image.
                Container(
                  width: double.infinity, // Sets button container to expand to max width.
                  child: ElevatedButton.icon(
                    onPressed: () { // Called when button is pressed.
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JournalScreen()), // Navigates to JournalScreen.
                      );
                    },
                    icon: Icon(Icons.book, size: 24), // Sets icon for the button.
                    label: Text(
                      'Open Journal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ), // Sets button label text and style.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor, // Sets button background color.
                      foregroundColor: Colors.white, // Sets text and icon color.
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Sets internal button padding.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounds button corners.
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8), // Adds vertical spacing below the button.
                Text(
                  'Start writing your mental health journey',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), // Sets text color with opacity.
                    fontSize: 14, // Sets font size.
                  ),
                  textAlign: TextAlign.center, // Centers text.
                ),
                SizedBox(height: 24), // Adds vertical spacing below prompt text.
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.primaryColor, // Sets border color from theme.
                      width: 2, // Sets border width.
                    ),
                    borderRadius: BorderRadius.circular(16), // Rounds container corners.
                    color: theme.brightness == Brightness.dark
                        ? Colors.white10 // Background color for dark mode.
                        : Colors.white, // Background color for light mode.
                  ),
                  padding: EdgeInsets.all(24), // Padding inside the container.
                  child: Text(
                    "Hello! I'm Brad, the creator of Reminest. Having personally experienced mental health challenges, I understand the importance of having a safe, private space for self-reflection and emotional expression.\n\n"
                    "Reminest is designed as your secure digital sanctuary—a place where you can document your thoughts, track your emotional journey, and reflect on your growth over time. The app's core purpose is to help you identify patterns in your mental health by allowing you to revisit entries months or years later.\n\n"
                    "Key features include:\n"
                    "• Secure journal entries with vault protection\n"
                    "• Photo integration with gallery or camera options\n"
                    "• Flexible organization between main journal and secure vault\n"
                    "• Privacy-focused design with no external sharing\n\n"
                    "In a world of constant social media exposure, Reminest provides a judgment-free environment where you can express yourself authentically. Whether you're managing anxiety, depression, or simply navigating life's challenges, this app serves as your personal mental health companion.\n\n"
                    "Thank you for trusting Reminest on your journey toward better mental wellness.", // Sets the about text and description.
                    style: TextStyle(
                      fontSize: 15, // Text font size.
                      color: theme.textTheme.bodyMedium?.color, // Text color from theme.
                      height: 1.5, // Line height.
                    ),
                    textAlign: TextAlign.left, // Aligns text to left.
                  ),
                ),
                SizedBox(height: 24), // Adds vertical spacing below about text.
                Text(
                  "Developed by Bradley Murray.\n© 2025",
                  textAlign: TextAlign.center, // Centers text.
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7), // Text color with opacity.
                    fontSize: 16, // Font size.
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
