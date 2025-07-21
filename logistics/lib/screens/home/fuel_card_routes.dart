import 'package:flutter/material.dart';
import 'package:logistics/models/fuel_card_models.dart';
import 'package:logistics/screens/home/add_transaction_screen.dart';
import 'package:logistics/screens/home/assignment_details_screen.dart';
import 'package:logistics/screens/home/create_fuel_card_screen.dart';
import 'package:logistics/screens/home/driver_fuel_card_screen.dart';
import 'package:logistics/screens/home/fuel_card_lockers_screen.dart';
import 'package:logistics/screens/home/fuel_card_management_screen.dart';
import 'package:logistics/screens/home/fuel_transactions_screen.dart';

class AssignFuelCardScreen extends StatelessWidget {
  const AssignFuelCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Fuel Card')),
      body: const Center(child: Text('Assign Fuel Card screen coming soon!')),
    );
  }
}

class FuelCardRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/fuel-card/management': (context) => const FuelCardManagementScreen(),
      '/fuel-card/driver': (context) {
        final driverId = ModalRoute.of(context)!.settings.arguments as String;
        return DriverFuelCardScreen(driverId: driverId);
      },
      '/fuel-card/create': (context) => const CreateFuelCardScreen(),
      '/fuel-card/lockers': (context) => const FuelCardLockersScreen(),
      '/fuel-card/add-transaction': (context) {
        final assignment =
            ModalRoute.of(context)!.settings.arguments as FuelCardAssignment;
        return AddTransactionScreen(assignment: assignment);
      },
      '/fuel-card/assignment-details': (context) {
        final assignment =
            ModalRoute.of(context)!.settings.arguments as FuelCardAssignment;
        return AssignmentDetailsScreen(assignment: assignment);
      },
      '/fuel-card/transactions': (context) {
        final cardId = ModalRoute.of(context)!.settings.arguments as String;
        return FuelTransactionsScreen(cardId: cardId);
      },
      '/fuel-card/assign': (context) => const AssignFuelCardScreen(),
    };
  }
}
