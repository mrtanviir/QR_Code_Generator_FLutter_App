import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/qr_generator_screen.dart';
import 'package:myapp/qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: ListView(
          children: [
            Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "QR Code",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 50),
              Center(
                child: Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildFeatureButtion(
                        context,
                        "Generate QR Code",
                        Icons.qr_code,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QrGeneratorScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                       _buildFeatureButtion(
                        context,
                        "Scan QR Code",
                        Icons.qr_code_scanner,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QrScannerScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ]
        ),
      ),
    );
  }

  Widget _buildFeatureButtion(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(15),
        height: 250,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 90, color: Colors.white,),
            Text(title,style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),)
          ],
        ),
      ),
    );
  }
}
