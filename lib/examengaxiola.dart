import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _currentRating = 0;
  bool _isLoading = false;
  bool _ratingSent = false;

  StateMachineController? controller;
  SMITrigger? trigSuccess; // Animación feliz
  SMITrigger? trigFail; // Animación triste
  SMIBool? isChecking; // Controla la atención del oso
  SMINumber? numLook; // Controla hacia dónde mira el oso

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // =======================================================
  // FUNCIÓN DE CALIFICACIÓN CORREGIDA
  // =======================================================
  void _setRating(int rating) {
    if (_ratingSent) return;

    isChecking?.change(true);
    numLook?.value = (rating / 5) * 100;

    setState(() {
      _currentRating = rating;
    });

    if (rating >= 4) {
      trigSuccess?.fire(); // Oso feliz
    } else {
      trigFail?.fire(); // Oso triste
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        isChecking?.change(false);
        numLook?.value = 50;
      }
    });
  }

  void _onRateNow() async {
    if (_currentRating == 0 || _isLoading) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Califica el curso del Profesor Gaxiola",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);

                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    isChecking = controller!.findSMI('isChecking');
                    numLook = controller!.findSMI('numLook');
                  },
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: index < _currentRating
                          ? Colors.amber
                          : Colors.grey,
                      size: 40,
                    ),
                    onPressed: _ratingSent ? null : () => _setRating(index + 1),
                  );
                }),
              ),

              const SizedBox(height: 20),

              if (_currentRating > 0)
                Text(
                  _currentRating >= 4
                      ? "¡Excelente! Nos alegra tu feedback."
                      : "Gracias, trabajaremos para mejorar.",
                  style: TextStyle(
                    color: _currentRating >= 4 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: _ratingSent || _isLoading
                        ? null
                        : () {
                            setState(() => _ratingSent = true);
                          },
                    child: const Text(
                      "No Thanks",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  MaterialButton(
                    minWidth: size.width * 0.4,
                    height: 50,
                    color: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: _isLoading || _currentRating == 0
                        ? null
                        : _onRateNow,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Rate Now",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
