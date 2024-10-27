// ignore_for_file: prefer_const_constructors,

import 'package:biometric_auth/homepage.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication localAuth = LocalAuthentication(); //Local Auth

  bool canAuthenticate = false;   // Biometric support
  bool authenticated = false;   // Biometric authentication

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  // Check if the device supports biometric authentication
  Future<void> _checkBiometricSupport() async {
    canAuthenticate = await localAuth.canCheckBiometrics;
    setState(() {
      canAuthenticate;
    });
  }
  
  // Biometric authentication
  Future<void> _authenticate(BuildContext context) async {
    try {
      // Authenticate the user
      authenticated = await localAuth.authenticate(
        localizedReason:  "Doğrulama yapmak için parmak izinizi kullanın", //Prompt message
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
              signInTitle: 'Biyometrik verileri kullanın',
              biometricHint:
                  'Kolay giriş için biyometrik verilerinizi kullanın',
              deviceCredentialsSetupDescription: "Parmak izi sensörüne dokunun",
              cancelButton: 'İptal',
              goToSettingsButton: "Ayarlar'a git",
              goToSettingsDescription:
                  "Ayarlar'a gidin ve biyometrik verilerinizi ayarlayın"),
        ],
        options: AuthenticationOptions(
            biometricOnly: true, // Only allows login with biometric data.
            stickyAuth: true, // If authentication is successful, it won't ask again.
            useErrorDialogs: true, // Shows error messages in case of an error.
            sensitiveTransaction: false, // Not used for sensitive transactions.
        ),
      );

      if (authenticated) {
        // Login successful!
        Navigator.push(
          context,MaterialPageRoute(builder: (context) => HomePage()),);

      } else {
        // Authentication failed
        _showErrorDialog('Doğrulama başarısız. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      // Handle errors (e.g., sensor unavailable)
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Giriş Başarısız!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 4,
            vertical: MediaQuery.of(context).size.height / 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/maskot.png'),
            SizedBox(
              height: 10,
            ),

            // In this line you can use the username of the user
            Text("Tekrar Hoşgeldiniz!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),

            // If canUseBiometric is true, then show the username and password fields
            if (!canAuthenticate) ...[
              TextField(
                decoration: InputDecoration(
                  hintText: 'Kullanıcı Adı',
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Şifre',
                ),
              ),
            ],
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  _authenticate(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 16),
                )),
            SizedBox(
              height: 10,
            ),
            Text(
              "veya",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              child: Text(
                canAuthenticate
                    ? "Email ve şifre ile giriş yap"
                    : "Biyometrik verilerle giriş yap",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
              onTap: () {
                setState(() {
                  canAuthenticate = !canAuthenticate;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

}
