import 'package:flutter/material.dart';
import 'package:jamb/ui/core/widgets/empty_background_screen.dart';
import 'package:jamb/ui/core/widgets/jamb_fab.dart';
import 'package:jamb/ui/calendario/widgets/calendario_widget.dart';
import 'package:jamb/ui/calendario/widgets/eventi_oggi_widget.dart';
import 'package:jamb/ui/calendario/widgets/prossimi_eventi_widget.dart';
import 'package:jamb/ui/calendario/widgets/crea_evento_screen.dart';

class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyBackgroundScreen(
      currentIndex: 3, // Indice per il Calendario
      floatingActionButton: JambFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreaEventoScreen()),
          );
        },
      ),
      child: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 120), // Spazio per la TopBar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CalendarioWidget(),
              ),
              EventiOggiWidget(),
              ProssimiEventiWidget(),
              SizedBox(height: 80), // Padding below for the bottom navbar
            ],
          ),
        ),
      ),
    );
  }
}
