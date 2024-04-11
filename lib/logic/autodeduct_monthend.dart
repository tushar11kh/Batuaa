import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'flutter_toast.dart';

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AutodeductMonthend {
  final DatabaseReference _ref = FirebaseDatabase.instance.reference().child('Users');
  final User _user = FirebaseAuth.instance.currentUser!;
  final DateTime _now = DateTime.now();

  void autodeductMonthend() {
    const oneDay = Duration(days: 1);
    Timer.periodic(oneDay, (timer) async {
      if (_now.day == 1) {
        debugPrint('End of month detected.');

        DatabaseReference splitRef = _ref.child(_user.uid).child('split');

        DataSnapshot snapshot = await splitRef.get();
        Map<dynamic, dynamic> splitData = snapshot.value as Map<dynamic, dynamic>;

        if (splitData != null) {
          int needIncome = splitData['needAvailableBalance'] ?? 0;
          int expensesIncome = splitData['expensesAvailableBalance'] ?? 0;
          int currentSavings = splitData['savings'] ?? 0;

          // Calculate new savings balance
          int updatedSavings = currentSavings + needIncome + expensesIncome;

          // Reset balances
          splitRef.update({
            'needAvailableBalance': 0,
            'expensesAvailableBalance': 0,
            'savings': updatedSavings,
          }).then((_) {
            // Transfer transactions to savings history
            _transferToSavingsHistory(splitRef, needIncome, expensesIncome);
            debugPrint('Month-end balance transferred to savings.');
          }).catchError((error) {
            debugPrint('Error transferring month-end balance: $error');
          });
        }
      }
    });
  }

  void _transferToSavingsHistory(DatabaseReference splitRef, int needIncome, int expensesIncome) {
    final DateTime now = DateTime.now();

    // Transaction details for expenses
    Map<String, dynamic> expensesTransaction = {
      'name': 'Transferred to Savings',
      'amount': expensesIncome,
      'shortDescription': 'Transferred to Savings from expenses',
      'paymentDateTime': now.toString(),
    };

    // Transaction details for need
    Map<String, dynamic> needTransaction = {
      'name': 'Transferred to Savings',
      'amount': needIncome,
      'shortDescription': 'Transferred to Savings from need',
      'paymentDateTime': now.toString(),
    };

    // Save transactions to history
    splitRef.child('expensesTransactions').push().set(expensesTransaction);
    splitRef.child('needTransactions').push().set(needTransaction);
  }
}
