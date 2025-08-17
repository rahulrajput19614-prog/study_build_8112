import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // 🔹 App Logo / Name
              Text(
                "Study Build",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Colors.deepPurple, Colors.blue, Colors.pink],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              const SizedBox(height: 40),

              // 🔹 Google Login Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Image.asset("assets/google_logo.png", height: 24),
                label: const Text(
                  "Continue with Google",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  // TODO: API call to Render backend
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Google Login Clicked")),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 🔹 Mobile Login Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text(
                  "Continue with Mobile",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MobileLoginScreen()),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Login with Mobile")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Mobile Number",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Call Render backend OTP API
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("OTP sent to ${phoneController.text}")),
                );
              },
              child: const Text("Send OTP"),
            )
          ],
        ),
      ),
    );
  }
}
