import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; // Aún útil para futuras animaciones, aunque no se use Timer

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  // Estado Local
  int _currentRating = 0; // Valor de 0 a 5
  bool _isLoading = false; // Estado de carga para el botón
  bool _feedbackGiven = false; // Bandera para evitar re-calificar

  // Cerebro de la lógica de animaciones SMI (Rive)
  StateMachineController? controller;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  // SMIBool, SMINumber y FocusNodes del login anterior se eliminan

  // La lógica del oso ahora solo usa triggers
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Lógica para disparar la animación al calificar
  void _setRating(int rating) {
    if (_feedbackGiven) return;

    setState(() {
      _currentRating = rating;
      if (rating >= 4) {
        trigSuccess?.fire();
      } else if (rating > 0) {
        trigFail?.fire();
      }
    });
  }

  // Aquí es para la Acción principal al presionar "Rate Now"
  void _onRateNow() async {
    if (_currentRating == 0 || _feedbackGiven) return;

    setState(() {
      _isLoading = true;
      _feedbackGiven = true;
    });

    // Simular envío de calificación por ~1s
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      // Aquí se navegaría a otra pantalla o se mostraría un mensaje final
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título de la calificación
              const Text(
                "Enjoying Router?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Animación Rive (Oso)
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv', // Usamos el mismo archivo
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);
                    // Enlazamos solo los triggers necesarios
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Estrellas de Calificación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      // Icono cambia si el índice es menor al rating actual
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: index < _currentRating
                          ? Colors.amber
                          : Colors.grey,
                      size: 40,
                    ),
                    onPressed: _feedbackGiven
                        ? null
                        : () => _setRating(index + 1),
                  );
                }),
              ),

              // Mensaje de feedback visual
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

              // Aquí es para poner los Botones de Acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botón "No Thanks"
                  TextButton(
                    onPressed: _feedbackGiven || _isLoading
                        ? null
                        : () {
                            // Simular que el usuario rechaza la acción
                            setState(() => _feedbackGiven = true);
                          },
                    child: const Text(
                      "No Thanks",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  // Aquí es para el espacio del Botón "Rate Now" (Principal)
                  MaterialButton(
                    minWidth: size.width * 0.4,
                    height: 50,
                    color: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed:
                        _isLoading || _currentRating == 0 || _feedbackGiven
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
