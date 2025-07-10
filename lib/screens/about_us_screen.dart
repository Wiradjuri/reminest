import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181818), // dark mode background

      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Color(0xFF9B59B6),
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
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text("🧠", style: TextStyle(fontSize: 32)),
                  ],
                ),
                SizedBox(height: 24),
                
                // Profile photo (update 'assets/me.jpg' with your image file)
                CircleAvatar(
                  radius: 54,
                  // backgroundImage: AssetImage('assets/me.jpg'),
                  backgroundColor: Colors.white24,
                ),
                SizedBox(height: 20),

                // About text with border
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF9B59B6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white10,
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
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Mental Health Support Numbers Section
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF9B59B6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white10,
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mental Health Support Numbers:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9B59B6),
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildSupportNumbers(),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                // Optional: Add developer's name/title
                Text(
                  "Developed by Bradley Murray.\n© 2025",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
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

  Widget _buildSupportNumbers() {
    // Define a dictionary (Map) for mental health support numbers
    final Map<String, Map<String, String>> mentalHealthSupportNumbers = {
      "Lifeline Australia": {
        "Phone": "13 11 14 (24/7)",
        "Text": "0477 13 11 14 (24/7)",
        "Online Chat": "Available 24/7 at lifeline.org.au",
        "Services": "Crisis support and suicide prevention for anyone in emotional distress.",
      },
      "Beyond Blue": {
        "Phone": "1300 22 4636 (24/7)",
        "Online Chat": "Available 24/7 at beyondblue.org.au",
        "Services": "Support for depression, anxiety, and mental wellbeing.",
      },
      "Kids Helpline": {
        "Phone": "1800 55 1800 (24/7)",
        "Online Chat": "Available 24/7 at kidshelpline.com.au",
        "Services": "Free, confidential counselling for young people aged 5–25.",
      },
      "headspace": {
        "Phone": "1800 650 890",
        "Online Support": "Available at headspace.org.au",
        "Services": "Mental health support for young people aged 12–25, including online and in-person counselling.",
      },
      "NSW Mental Health Line": {
        "Phone": "1800 011 511 (24/7)",
        "Services": "Statewide service offering mental health advice, assessment, and referrals to NSW Health services.",
      },
      "13YARN": {
        "Phone": "13 92 76 (24/7)",
        "Services": "Culturally safe crisis support for Aboriginal and Torres Strait Islander peoples.",
      },
      "MensLine Australia": {
        "Phone": "1300 78 99 78 (24/7)",
        "Online Chat": "Available at mensline.org.au",
        "Services": "Support for men dealing with relationship issues, stress, and emotional wellbeing.",
      },
      "Suicide Call Back Service": {
        "Phone": "1300 659 467 (24/7)",
        "Online Chat": "Available at suicidecallbackservice.org.au",
        "Services": "Counselling for individuals affected by suicide.",
      },
      "QLife": {
        "Phone": "1800 184 527 (3pm–midnight)",
        "Online Chat": "Available at qlife.org.au",
        "Services": "Support for LGBTQIA+ individuals.",
      },
      "Alcohol and Drug Information Service (ADIS)": {
        "Phone": "1800 250 015 (24/7)",
        "Services": "Information and support for alcohol and drug-related issues.",
      },
    };

    return Column(
      children: [
        for (int i = 0; i < mentalHealthSupportNumbers.entries.length; i += 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: _buildSupportCard(
                  mentalHealthSupportNumbers.entries.elementAt(i).key,
                  mentalHealthSupportNumbers.entries.elementAt(i).value,
                ),
              ),
              SizedBox(width: 12),
              // Right column
              Expanded(
                child: i + 1 < mentalHealthSupportNumbers.entries.length
                    ? _buildSupportCard(
                        mentalHealthSupportNumbers.entries.elementAt(i + 1).key,
                        mentalHealthSupportNumbers.entries.elementAt(i + 1).value,
                      )
                    : SizedBox(), // Empty space if odd number of items
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSupportCard(String service, Map<String, String> details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            ...details.entries.map((detail) => Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                "${detail.key}: ${detail.value}",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
